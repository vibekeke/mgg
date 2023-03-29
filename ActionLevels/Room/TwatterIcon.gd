extends TextureRect

onready var parent_node = self.get_parent()
onready var birder = get_node("%Birder")

func has_notification():
	$NotifyIcon.visible = true

func remove_notification():
	$NotifyIcon.visible = false

func click():
	bring_to_front()
	birder.visible = !birder.visible

func bring_to_front():
	parent_node.move_child(birder, parent_node.get_child_count())

func _on_TwatterIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()
			remove_notification()
