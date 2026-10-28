# coding:utf-8

from PySide6.QtCore import QPoint


def show_chat_window(owner, history=None, append_message=None, content_for_llm=None, system_prompt_builder=None, clear_history_callback=None, send_callback=None, backend='minipet', backend_select_callback=None, cancel_callback=None):
    from windows.chat_window import ChatWindow
    import config

    if owner.quick_menu is not None:
        owner.quick_menu.close()
    if owner.chat_window is None:
        owner.chat_window = ChatWindow(config.pet_display_name(), owner, history=history, append_message=append_message, content_for_llm=content_for_llm, system_prompt_builder=system_prompt_builder, clear_history_callback=clear_history_callback, send_callback=send_callback, backend=backend, backend_select_callback=backend_select_callback, cancel_callback=cancel_callback)
        window = owner.chat_window
        window.opened.connect(lambda: owner.companion.conversation('opened', window.geometry().center()))
        window.dismissed.connect(lambda: owner.companion.conversation('closed'))
        window.typing_changed.connect(lambda typing: owner.companion.conversation(
            'typing', window.input.mapToGlobal(window.input.rect().center()) if typing else window.geometry().center()))
    else:
        owner.chat_window.set_pet_name(config.pet_display_name())
        owner.chat_window.append_message = append_message
        owner.chat_window.content_for_llm = content_for_llm
        owner.chat_window.system_prompt_builder = system_prompt_builder
        owner.chat_window.clear_history_callback = clear_history_callback
        owner.chat_window.send_callback = send_callback
        owner.chat_window.cancel_callback = cancel_callback
        owner.chat_window.backend_select_callback = backend_select_callback
        owner.chat_window.set_backend(backend)
        # 只在查看的正是全局后端对话时同步历史；查看其他对话时保留用户视图，
        # 避免把别的后端历史塞进当前视图导致徽标与内容错位
        if history is not None and owner.chat_window.backend == backend:
            if owner.chat_window.history is not history:
                owner.chat_window.history = history
                owner.chat_window.reload_history()
    window = owner.chat_window
    if window.compact and not window.isVisible():
        screen = owner._screen_at_point(QPoint(*owner.reply_card_anchor()))
        area = screen.availableGeometry()
        x = owner.geometry().right() + 12
        if x + window.width() > area.right():
            x = owner.x() - window.width() - 12
        y = owner.reply_card_anchor()[1]
        window.move(max(area.left(), min(x, area.right() - window.width() + 1)),
                    max(area.top(), min(y, area.bottom() - window.height() + 1)))
    window.show_window()


