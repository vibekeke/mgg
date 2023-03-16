extends PanelContainer

func _ready():
	pass
	#$MarginContainer/VBoxContainer/ChatText.margin_left = 5
	#print("changed margin in chat text")

func add_message_text(text_to_add):
	$MarginContainer/VBoxContainer/ChatText.set_text(text_to_add)
