extends TextureRect

onready var parent_node = self.get_parent()
onready var chat_app = get_node("%ChatApp")

func click():
	bring_to_front()
	chat_app.visible = !chat_app.visible

func bring_to_front():
	parent_node.move_child(chat_app, parent_node.get_child_count())

func _on_ChatIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()

