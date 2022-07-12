extends TextureRect


func _ready():
	var area2d = get_node("Area2D")
	area2d.connect("input_event", self, "_on_Area2D_input_event")

func click():
	print("Clicked")

func _on_Area2D_input_event(viewport, event, shape_idx):
	print("clicked?")
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			click()
