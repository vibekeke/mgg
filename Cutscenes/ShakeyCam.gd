extends Node

export var handcam_intensity: float = 2.0
export var handcam_frequency: float = 2.0

var camera: Camera2D
var time: float = 0.0

func _ready():
	camera = get_parent()

func _process(delta):
	time += delta
	var shake_amount = handcam_intensity * (0.5 + 0.5 * sin(time * handcam_frequency))
	camera.add_trauma(shake_amount * delta)
