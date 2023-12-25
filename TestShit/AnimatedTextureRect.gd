class_name AnimatedTextureRect extends TextureRect
export var sprites : SpriteFrames
export var current_animation = "default"
export var frame_index = 0
export(float, 0.0, 1000000, 0.001) var speed_scale := 1.0
export var auto_play := false
export var playing := false
var refresh_rate = 1.0
var fps = 60.0
var frame_delta = 0


func _ready():
	pass
