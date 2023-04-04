extends PanelContainer

func _ready():
	if OS.get_window_size().y < 1080:
		var chat_text = get_node("%ChatText")
		var font = chat_text.get_font("font")
		font.size = 42
		chat_text.add_font_override("font", font)

func add_message_text(text_to_add):
	$MarginContainer/VBoxContainer/ChatText.set_text(text_to_add)
