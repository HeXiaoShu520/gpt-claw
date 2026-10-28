# coding:utf-8
"""
gpt-claw 桌面通道客户端。

负责连接本机 gpt-claw、发送输入、接收回复与确认事件。
"""

import asyncio
import json
import socket
from pathlib import Path

import uuid
from urllib.parse import urlparse

import websockets
from websockets.exceptions import ConnectionClosed
from PySide6.QtCore import QThread, Signal

import config

from log_util import get_logger
from protocols.protocol_v1 import SESSION_HELLO, SESSION_PROBE, SESSION_PROBE_RESULT, SESSION_READY, SESSION_RESET, SESSION_RESET_RESULT, USER_APPROVAL, USER_CANCEL, USER_INPUT, hello_payload, normalize_inbound_event, probe_payload


DISCOVERY_FILE = Path(__file__).resolve().parents[3] / 'data' / 'desktop-connection.json'
log = get_logger('desktop.channel')


def _connection():
    """Read the current gpt-claw instance; its token changes on every start."""
    data = json.loads(DISCOVERY_FILE.read_text(encoding='utf-8'))
    if data.get('protocol') != 'minipet.v1' or not str(data.get('url', '')).startswith('ws://127.0.0.1:'):
        raise ValueError('gpt-claw 桌面通道配置无效')
    return data['url'], {'Authorization': 'Bearer ' + data['token']}


async def _probe_minipet_backend_async(timeout=3):
    """异步执行一次 session.probe 握手，返回 (是否通过, 说明文本)。"""
    # 每次探测生成唯一 request_id，用于核对响应归属，防止旧响应被误判为检测通过
    request_id = 'probe_' + uuid.uuid4().hex
    target, headers = _connection()
    async with websockets.connect(target, additional_headers=headers, ping_interval=None, open_timeout=timeout, close_timeout=1) as ws:
        await ws.send(json.dumps({
            'version': '1.0',
            'type': SESSION_PROBE,
            'request_id': request_id,
            'payload': probe_payload(),
        }, ensure_ascii=False))
        raw = await asyncio.wait_for(ws.recv(), timeout=timeout)
        event = normalize_inbound_event(json.loads(raw))
        if event.get('type') != SESSION_PROBE_RESULT:
            return False, '后端已连接，但未返回 session.probe.result。'
        if event.get('request_id') and event.get('request_id') != request_id:
            return False, '后端返回了检测结果，但 request_id 不匹配。'
        payload = event.get('payload') if isinstance(event.get('payload'), dict) else {}
        protocol = payload.get('protocol') or ''
        if protocol and protocol != 'minipet.v1':
            return False, '后端协议不匹配：' + str(protocol)
        server = payload.get('server') if isinstance(payload.get('server'), dict) else {}
        name = server.get('name') or payload.get('name') or 'gpt-claw 桌面服务'
        return True, '协议检测通过：' + str(name)


def probe_minipet_backend(timeout=3):
    """通过 session.probe 检测 gpt-claw 桌面服务（同步入口，异常转为说明文本）。"""
    try:
        target, _ = _connection()
    except (OSError, ValueError, KeyError) as exc:
        return False, 'gpt-claw 尚未启动：' + str(exc)
    parsed = urlparse(target)
    host = parsed.hostname
    port = parsed.port or (443 if parsed.scheme == 'wss' else 80)
    if not host:
        return False, '后端地址缺少主机名。'
    try:
        return asyncio.run(_probe_minipet_backend_async(timeout=timeout))
    except TimeoutError:
        return False, f'连接或等待检测结果超时：{host}:{port}'
    except asyncio.TimeoutError:
        return False, f'等待检测结果超时：{host}:{port}'
    except OSError as exc:
        message = str(exc) or exc.__class__.__name__
        if isinstance(exc, ConnectionRefusedError):
            return False, f'连接被拒绝：{host}:{port} 没有服务监听。'
        if isinstance(exc, socket.gaierror):
            return False, '无法解析后端地址：' + message
        return False, f'连接 gpt-claw 桌面服务失败：{message}'
    except Exception as exc:
        return False, '桌面连接检测失败：' + (str(exc) or exc.__class__.__name__)


class EventClient(QThread):
    """后台 WebSocket 客户端，向 UI 线程发出规范化事件。"""

    event_received = Signal(dict)
    connection_changed = Signal(bool)
    ready_changed = Signal(bool, str)
    reset_result = Signal(str, bool, str)

    def __init__(self, session_id, parent=None):
        """Connect to the sole gpt-claw instance discovered at runtime."""
        super().__init__(parent)
        self.running = True
        self.loop = None
        self.ws = None
        self.client_id = 'minipet-' + uuid.uuid4().hex
        self.session_id = session_id
        self.ready = False
        self._connected = False
        self._listen_task = None
        self._pending_inputs = {}

    def run(self):
        """QThread 主入口：在独立事件循环中运行监听协程直到线程停止。"""
        loop = asyncio.new_event_loop()
        self.loop = loop
        asyncio.set_event_loop(loop)
        self._listen_task = loop.create_task(self._listen())
        if not self.running:
            self._listen_task.cancel()
        try:
            loop.run_until_complete(self._listen_task)
        except asyncio.CancelledError:
            pass
        finally:
            pending = asyncio.all_tasks(loop)
            for task in pending:
                task.cancel()
            loop.run_until_complete(asyncio.gather(*pending, return_exceptions=True))
            loop.run_until_complete(loop.shutdown_asyncgens())
            loop.close()
            self._listen_task = None
            self.loop = None

    async def _listen(self):
        """监听主循环：握手后进入 ready，断线按退避策略重连。"""
        retry_delay = 1
        while self.running:
            try:
                target, headers = _connection()
                async with websockets.connect(target, additional_headers=headers, ping_interval=20, ping_timeout=20, close_timeout=1, max_size=40 * 1024 * 1024) as ws:
                    self.ws = ws
                    self._connected = True
                    self.ready = False
                    self.connection_changed.emit(True)
                    await self._send({
                        'version': '1.0',
                        'type': SESSION_HELLO,
                        'payload': hello_payload({
                            'id': self.client_id,
                            'name': config.APP_DISPLAY_NAME,
                            'version': '1.0',
                        }, session_id=self.session_id),
                    })
                    async for raw in ws:
                        if not self.running:
                            break
                        try:
                            event = self._normalize(json.loads(raw))
                            event_type = event.get('type')
                            if event_type in ('input.accepted', 'error'):
                                receipt = self._pending_inputs.get(event.get('request_id'))
                                if receipt is not None and not receipt.done():
                                    payload = event.get('payload') or {}
                                    receipt.set_result(str(payload.get('message') or '输入未被接收') if event_type == 'error' else None)
                                if event_type == 'input.accepted' or receipt is not None:
                                    continue
                            if event_type == SESSION_READY:
                                payload = event.get('payload') if isinstance(event.get('payload'), dict) else {}
                                server = payload.get('server') if isinstance(payload.get('server'), dict) else {}
                                name = str(server.get('name') or payload.get('name') or '智能体')
                                self.ready = True
                                retry_delay = 1
                                self.ready_changed.emit(True, name)
                            elif event.get('type') == SESSION_RESET_RESULT:
                                payload = event.get('payload') if isinstance(event.get('payload'), dict) else {}
                                self.reset_result.emit(str(event.get('request_id') or ''), bool(payload.get('accepted')), str(payload.get('message') or ''))
                                continue
                            self.event_received.emit(event)
                        except Exception as error:
                            log.warning('桌面事件解析失败：%s', error)
            except Exception:
                # 清除连接与授权状态后再退避重连。
                pass
            finally:
                if self.ready:
                    self.ready = False
                    self.ready_changed.emit(False, '')
                if self._connected:
                    self.connection_changed.emit(False)
                self._connected = False
                self.ws = None
            if self.running:
                await asyncio.sleep(retry_delay)
                retry_delay = min(retry_delay * 2, 10)

    def _normalize(self, data):
        """为缺失 type/priority 的消息补默认值，再交给协议 V1 规范化。"""
        if not isinstance(data, dict):
            return normalize_inbound_event(data)
        event = dict(data)
        event.setdefault('type', 'message')
        event.setdefault('priority', 'normal')
        return normalize_inbound_event(event)


    async def _send(self, payload, expected_ws=None):
        """在事件循环内发送一条 JSON 消息；连接不存在时返回 False。"""
        ws = self.ws
        if ws is None or (expected_ws is not None and ws is not expected_ws):
            return False
        await ws.send(json.dumps(payload, ensure_ascii=False))
        return True

    async def _send_input(self, message, ws):
        """等待服务落库确认；未确认时不自动重放可能已执行的输入。"""
        request_id = message['request_id']
        receipt = asyncio.get_running_loop().create_future()
        self._pending_inputs[request_id] = receipt
        try:
            try:
                if not await self._send(message, ws):
                    raise ConnectionError('桌面连接已断开，消息尚未发送。')
            except ConnectionClosed:
                # 发送结果不确定，等待重连后的接收确认，不重发输入。
                pass
            try:
                error = await asyncio.wait_for(receipt, timeout=20)
            except asyncio.TimeoutError as exc:
                raise TimeoutError('接收确认超时，消息可能已接收，请先检查回复记录。') from exc
            if error:
                raise RuntimeError(error)
            return True
        finally:
            self._pending_inputs.pop(request_id, None)
            if not receipt.done():
                receipt.cancel()

    def send_event(self, event_type, payload=None, request_id=None):
        """线程安全地提交事件；True 表示已提交，接收失败通过 error 事件返回。"""
        return self._send_event_message(event_type, payload, request_id)

    def send_v1_event(self, v1_type, payload=None, request_id=None):
        """线程安全地发送一条协议 V1 类型事件。"""
        return self._send_event_message(v1_type, payload, request_id)

    def _send_event_message(self, event_type, payload=None, request_id=None):
        """Only the authenticated live connection may send desktop actions."""
        message = {
            'version': '1.0',
            'type': event_type,
            'payload': payload or {},
        }
        if request_id:
            message['request_id'] = request_id
        elif event_type == USER_INPUT:
            message['request_id'] = 'input_' + uuid.uuid4().hex
        loop = self.loop
        ws = self.ws
        # An offline action must be reported as unsent; a guessed HTTP endpoint is unsafe.
        if self.ready and loop is not None and ws is not None and loop.is_running():
            try:
                operation = self._send_input(message, ws) if event_type == USER_INPUT else self._send(message, ws)
                future = asyncio.run_coroutine_threadsafe(operation, loop)
                def report_failure(result):
                    if not self.running or result.cancelled():
                        return
                    try:
                        if result.result():
                            return
                        raise RuntimeError('桌面连接已断开')
                    except Exception as error:
                        if event_type == SESSION_RESET:
                            self.reset_result.emit(str(request_id or ''), False, str(error))
                            return
                        self.event_received.emit({
                            'type': 'error',
                            'request_id': str(message.get('request_id') or ''),
                            'payload': {
                                'message': str(error),
                                'failed_event': event_type,
                                'turn_id': message['payload'].get('turn_id', ''),
                                'session_id': message['payload'].get('session_id', ''),
                            },
                        })
                future.add_done_callback(report_failure)
                return True
            except Exception:
                pass
        return False

    def execute_action(self, event, action):
        """把卡片按钮点击转换为 user_input 文本事件发往后端。"""
        action_text = action.get('label') or action.get('text') or action.get('id') or action.get('type') or '确认'
        values = event.get('values')
        if values:
            action_text += '\n' + json.dumps(values, ensure_ascii=False)
        payload = {'text': action_text}
        # 按钮动作必须回到原会话，
        # 看起来就像“点击后忘记上下文”。
        for key in ('session_id', 'turn_id', 'surface_id'):
            value = event.get(key)
            if value:
                payload[key] = value
        return self.send_event(USER_INPUT, payload)

    def execute_approval(self, event, action):
        """把本地授权按钮作为结构化 user.approval 发送，不降级成普通文本。"""
        payload = {}
        for key in ('approval_id', 'token', 'decision'):
            value = action.get(key)
            if value:
                payload[key] = value
        message_id = event.get('approval_message_id')
        if message_id:
            payload['message_id'] = message_id
        if payload.get('decision') == 'text':
            values = event.get('values') if isinstance(event.get('values'), dict) else {}
            payload['decision'] = str(values.get('answer') or '').strip()
        for key in ('session_id', 'turn_id', 'surface_id'):
            value = event.get(key)
            if value:
                payload[key] = value
        if not payload.get('approval_id') or not payload.get('token') or not payload.get('decision'):
            return False
        return self.send_event(USER_APPROVAL, payload)

    def cancel_turn(self, session_id='', turn_id='', surface_id=''):
        """请求 gpt-claw 中断当前 Codex 轮次。"""
        payload = {}
        for key, value in (('session_id', session_id), ('turn_id', turn_id), ('surface_id', surface_id)):
            if value:
                payload[key] = value
        return self.send_event(USER_CANCEL, payload)

    def request_reset(self):
        """Ask gpt-claw to reset the Codex thread; local history waits for its reply."""
        request_id = 'reset_' + uuid.uuid4().hex
        if self.send_event(SESSION_RESET, {'session_id': self.session_id}, request_id=request_id):
            return request_id
        return ''

    def reconnect(self):
        """用指定地址重连：关闭当前连接后由 _listen 自动重建。"""
        loop = self.loop
        ws = self.ws
        # 主动关闭当前连接，让 _listen 的重连逻辑接管，而不是直接新建连接
        if loop is not None and ws is not None and loop.is_running():
            try:
                asyncio.run_coroutine_threadsafe(ws.close(), loop)
            except Exception:
                pass

    def stop(self):
        """取消监听（包括重连等待），收尾协程后等待线程退出。"""
        self.running = False
        self.ready = False
        loop = self.loop
        task = self._listen_task
        if loop is not None and task is not None:
            loop.call_soon_threadsafe(task.cancel)
        self.wait()
