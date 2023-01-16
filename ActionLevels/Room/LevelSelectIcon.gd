extends TextureRect

onready var level_select = get_node("%LevelSelect")

func _ready():
	var area2d = get_node("Area2D")
	print("got area 2d in level select icon", area2d)
	area2d.connect("input_event", self, "_on_Area2D_input_event")

func click():
	print("making level select visible")
	level_select.visible = !level_select.visible

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()
