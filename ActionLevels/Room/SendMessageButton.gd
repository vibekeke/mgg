extends Button
export var red_color : float = 0
export var green_color : float = 0
export var blue_color : float = 0

func _ready():
	self.self_modulate = Color(red_color / 255.0 * 1.2, green_color / 255.0 * 1.2, blue_color / 255.0 * 1.2, 1.0)
	pass
