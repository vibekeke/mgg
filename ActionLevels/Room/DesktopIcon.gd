extends TextureRect

class_name DesktopIcon

export (Texture) var idle_texture
export (Texture) var hover_texture
export (Texture) var click_texture

func _ready():
	self.texture = idle_texture

func click():
	var test = get_node_or_null("../BSN")
	test.visible = !test.visible

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			click()
