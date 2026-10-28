"""Window-scoped structured adapter for Windows-MCP 0.8.8. No input tools.

Upstream Snapshot renders text and enumerates the desktop. Reuse its Tree
collector directly so only host-authorized HWNDs enter UIA and no text parser
is needed. Keep this adapter versioned with the upstream dependency.
"""

import asyncio
import logging
from concurrent.futures import ThreadPoolExecutor
from importlib.metadata import version

from fastmcp import FastMCP
from pydantic import BaseModel, Field

logging.disable(logging.CRITICAL)  # Upstream logs can contain UI text.
VERSION = "0.8.8"
if version("windows-mcp") != VERSION:
    raise RuntimeError("Unsupported Windows-MCP version; run computer:setup")

mcp = FastMCP("gpt-claw-windows-observer")
worker = ThreadPoolExecutor(max_workers=1, thread_name_prefix="uia")
desktop = None


def create_desktop():
    from windows_mcp.desktop.service import Desktop
    from windows_mcp.tree.cache_utils import CachedControlHelper
    from windows_mcp.tree.config import INTERACTIVE_CONTROL_TYPE_NAMES
    from windows_mcp.tree.service import Tree
    from windows_mcp.tree.views import SemanticNode
    from windows_mcp.uia import PropertyId

    class ScopedTree(Tree):
        """Extend the existing walk with text and identity, without a second walk."""
        def get_state(self, *args, **kwargs):
            self.details, self.labels = {}, []
            self.visited, self.adapter_truncated = 0, False
            result = super().get_state(*args, **kwargs)
            result.truncated = result.truncated or self.adapter_truncated
            return result

        def tree_traversal(self, node, window_box, window_name, is_browser, *args, **kwargs):
            self.visited += 1
            if self.visited > 1024:
                self.adapter_truncated = True
                return
            if not hasattr(node, '_is_cached') and kwargs.get('element_cache_req'):
                node = CachedControlHelper.build_cached_control(node, kwargs['element_cache_req'])
            try:
                name, role = node.CachedName.strip(), node.CachedControlTypeName
                box = self.iou_bounding_box(window_box, node.CachedBoundingRectangle)
                if name and not node.CachedIsOffscreen and box.width > 0 and box.height > 0:
                    identity = node.GetCachedPropertyValue(PropertyId.RuntimeIdProperty)
                    self.details[(name, box.left, box.top, box.width, box.height)] = {
                        'identity': ':'.join(str(int(part)) for part in identity) if identity else None,
                        'role': role, 'enabled': bool(node.CachedIsEnabled),
                    }
                    # Upstream omits ordinary desktop labels and disabled controls.
                    # Include them for observation/waiting; they never become input targets.
                    if role == 'TextControl' or (not node.CachedIsEnabled and role in INTERACTIVE_CONTROL_TYPE_NAMES):
                        self.labels.append(SemanticNode(control_type=role, element_type='text', name=name,
                            bounding_box=box, metadata={'has_focused': bool(node.CachedHasKeyboardFocus)}))
            except Exception:
                self.adapter_truncated = True
            return super().tree_traversal(node, window_box, window_name, is_browser, *args, **kwargs)

    instance = Desktop()
    instance.tree = ScopedTree(instance)
    return instance


class WindowTarget(BaseModel):
    window_id: int = Field(gt=0)
    pid: int = Field(gt=0)


def collect(targets: list[WindowTarget]) -> dict:
    # Imports and all COM/UIA use stay on the same dedicated worker thread.
    global desktop
    import win32gui
    import win32process

    def validate(target):
        if (not win32gui.IsWindow(target.window_id)
                or not win32gui.IsWindowVisible(target.window_id)
                or win32gui.IsIconic(target.window_id)
                or win32process.GetWindowThreadProcessId(target.window_id)[1] != target.pid):
            raise ValueError("Target window changed; observe again")

    for target in targets:
        validate(target)
    desktop = desktop or create_desktop()
    elements, truncated = [], False
    for target in targets:
        state = desktop.tree.get_state(target.window_id, [], use_dom=False)
        if not state.status:
            raise ValueError("UIA capture incomplete; use screenshot or retry observation")
        truncated = truncated or state.truncated
        pending = list(reversed(desktop.tree.labels))
        if state.semantic_tree_root:
            pending.append(state.semantic_tree_root)
        while pending:
            node = pending.pop()
            pending.extend(reversed(node.children))
            if node.element_type in ("desktop", "window"):
                continue
            if len(elements) >= 256:
                truncated = True
                break
            box = node.bounding_box
            if not box or box.width <= 0 or box.height <= 0:
                continue
            password = bool(node.metadata.get("is_password"))
            detail = desktop.tree.details.get((node.name, box.left, box.top, box.width, box.height), {})
            elements.append({
                "window_id": target.window_id,
                "identity": detail.get('identity'),
                "name": "[password]" if password else str(node.name)[:300],
                "role": str(detail.get('role', node.control_type))[:80],
                "bounds": {"x": box.left, "y": box.top, "width": box.width, "height": box.height},
                "actionable": node.element_type in ("interactive", "scrollable") and not password and bool(detail.get('identity')),
                "enabled": bool(detail.get('enabled', False)),
                "focused": bool(node.metadata.get("has_focused")),
                "toggle": str(node.metadata.get("toggle_state", ""))[:20],
            })
        validate(target)
    return {"schema_version": 1, "backend_version": VERSION, "elements": elements, "truncated": truncated}


@mcp.tool(name="ObserveWindow", annotations={"readOnlyHint": True, "destructiveHint": False})
async def observe_window(windows: list[WindowTarget]) -> dict:
    """Read controls only from explicitly supplied, process-bound windows."""
    if not 1 <= len(windows) <= 8 or len({w.window_id for w in windows}) != len(windows):
        raise ValueError("Expected 1-8 unique windows")
    try:
        return await asyncio.get_running_loop().run_in_executor(worker, collect, windows)
    except Exception:
        # Do not relay provider exceptions containing screen text or document data.
        raise ValueError("Window observation failed; target changed or UIA provider unavailable") from None


if __name__ == "__main__":
    mcp.run(transport="stdio", show_banner=False)
