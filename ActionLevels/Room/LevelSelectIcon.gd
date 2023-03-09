extends TextureRect

onready var level_select = get_node("%LevelSelect")
onready var mouse_click = get_node("%MouseClick")

func click():
	level_select.visible = !level_select.visible

func _on_LevelSelectIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()

