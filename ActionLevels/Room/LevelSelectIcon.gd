extends TextureRect

onready var level_select = get_node("%LevelSelect")
onready var parent_node = self.get_parent()

func has_notification():
	$NotifyIcon.visible = true

func remove_notification():
	$NotifyIcon.visible = false

func click():
	bring_to_front()
	level_select.visible = !level_select.visible

func bring_to_front():
	parent_node.move_child(level_select, parent_node.get_child_count())

func _on_LevelSelectIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()
			remove_notification()

