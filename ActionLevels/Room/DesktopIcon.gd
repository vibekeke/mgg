extends TextureRect

class_name DesktopIcon

export (Texture) var idle_texture
export (Texture) var hover_texture
export (Texture) var click_texture

func _ready():
	self.texture = idle_texture

func click():
	pass
