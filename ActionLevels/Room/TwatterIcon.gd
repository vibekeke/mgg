extends TextureRect

onready var birder = get_node("%Birder")

func click():
	birder.visible = !birder.visible

func _on_TwatterIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()
