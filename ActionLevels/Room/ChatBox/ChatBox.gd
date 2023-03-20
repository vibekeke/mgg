extends Control

const player_chat_panel = preload("res://ActionLevels/Room/ChatBox/SettableChatPanel.tscn")
const receiver_chat_panel = preload("res://ActionLevels/Room/ChatBox/SettableChatPanelCounterpart.tscn")

func create_player_panel(text_for_panel):
	var _instanced_player_chat_panel = player_chat_panel.instance()
	_instanced_player_chat_panel.add_message_text(text_for_panel)
	$ScrollContainer/VBoxContainer.add_child(_instanced_player_chat_panel)
	yield(get_tree(), "idle_frame")
	$ScrollContainer.ensure_control_visible(_instanced_player_chat_panel)

func create_counterpart_panel(text_for_panel):
	var _instanced_counterpart_chat_panel = receiver_chat_panel.instance()
	_instanced_counterpart_chat_panel.add_message_text(text_for_panel)
	$ScrollContainer/VBoxContainer.add_child(_instanced_counterpart_chat_panel)
	yield(get_tree(), "idle_frame")
	$ScrollContainer.ensure_control_visible(_instanced_counterpart_chat_panel)
	
