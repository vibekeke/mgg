extends TextureRect

class_name DesktopIcon

export (Texture) var idle_texture
export (Texture) var hover_texture
export (Texture) var click_texture
onready var bsn = get_node("%BSN")

func _ready():
	self.texture = idle_texture
	var area2d = get_node("Area2D")
	print(area2d)
	area2d.connect("input_event", self, "_on_Area2D_input_event")

func click():
	print("visibility is ", bsn.visible)
	bsn.visible = !bsn.visible

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()
