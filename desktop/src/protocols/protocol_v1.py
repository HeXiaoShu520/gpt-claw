# coding:utf-8
"""gpt-claw 与桌宠的桌面通信协议 V1 常量与辅助函数。

协议版本号写入每条消息，握手时通告支持的事件类型。
"""

PROTOCOL = 'minipet.v1'

# 会话生命周期事件
SESSION_HELLO = 'session.hello'
SESSION_READY = 'session.ready'
SESSION_PROBE = 'session.probe'
SESSION_PROBE_RESULT = 'session.probe.result'
SESSION_RESET = 'session.reset'
SESSION_RESET_RESULT = 'session.reset.result'
SESSION_PING = 'session.ping'
SESSION_PONG = 'session.pong'

# 业务事件
USER_INPUT = 'user.input'
USER_CANCEL = 'user.cancel'
USER_APPROVAL = 'user.approval'
SURFACE_SHOW = 'surface.show'
SURFACE_UPDATE = 'surface.update'
SURFACE_CLOSE = 'surface.close'
SURFACE_ACK = 'surface.ack'
AGENT_STATE = 'agent.state'
SCREEN_SHARE_SET = 'screen.share.set'
SCREEN_SHARE_STATE = 'screen.share.state'
SCREEN_CONTROL_STATE = 'screen.control.state'
SCREEN_CAPTURE_REQUEST = 'screen.capture.request'
SCREEN_CAPTURE_RESULT = 'screen.capture.result'
PET_GUIDE_REQUEST = 'pet.guide.request'
PET_GUIDE_RESULT = 'pet.guide.result'

# 握手时声明的能力列表（不含 AGENT_STATE，因其属于宠物端单向推送）
V1_CAPABILITIES = [
    SESSION_HELLO,
    SESSION_READY,
    SESSION_PROBE,
    SESSION_PROBE_RESULT,
    SESSION_RESET,
    SESSION_RESET_RESULT,
    SESSION_PING,
    SESSION_PONG,
    USER_INPUT,
    USER_CANCEL,
    USER_APPROVAL,
    SURFACE_SHOW,
    SURFACE_UPDATE,
    SURFACE_CLOSE,
    SURFACE_ACK,
    SCREEN_SHARE_SET,
    SCREEN_SHARE_STATE,
    SCREEN_CONTROL_STATE,
    SCREEN_CAPTURE_REQUEST,
    SCREEN_CAPTURE_RESULT,
    PET_GUIDE_REQUEST,
    PET_GUIDE_RESULT,
]


def normalize_inbound_event(event):
    # 界面只接受结构化事件；无效消息统一转成可见文本。
    if not isinstance(event, dict):
        return {
            'version': '1.0',
            'type': SURFACE_SHOW,
            'payload': {
                'content': str(event),
            },
        }
    data = dict(event)
    data.setdefault('version', '1.0')
    data.setdefault('payload', {})
    return data


def hello_payload(client=None, session_id=''):
    payload = {
        'protocol': PROTOCOL,
        'capabilities': list(V1_CAPABILITIES),
    }
    if isinstance(client, dict):
        payload['client'] = dict(client)
    if session_id:
        payload['session_id'] = session_id
    return payload


def probe_payload():
    return {
        'protocol': PROTOCOL,
        'capabilities': list(V1_CAPABILITIES),
    }
