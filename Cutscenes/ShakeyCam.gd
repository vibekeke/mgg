extends Node

export var shake_intensity: float = 15.0
export var rotation_intensity: float = 0.01
export var shake_duration_min: float = 1.5
export var shake_duration_max: float = 3.0

var camera: Camera2D
var tween: Tween
var base_position: Vector2
var base_rotation: float

func _ready():
	camera = get_parent()
	base_position = camera.position
	base_rotation = camera.rotation
	tween = Tween.new()
	add_child(tween)
	tween.connect("tween_all_completed", self, "_on_shake_complete")
	start_next_shake()

func start_next_shake():
	var duration = rand_range(shake_duration_min, shake_duration_max)
	var target_offset = Vector2(
		rand_range(-shake_intensity, shake_intensity),
		rand_range(-shake_intensity, shake_intensity)
	)
	var target_rotation = base_rotation + rand_range(-rotation_intensity, rotation_intensity)

	tween.interpolate_property(camera, "position",
		camera.position, base_position + target_offset,
		duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera, "rotation",
		camera.rotation, target_rotation,
		duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func _on_shake_complete():
	start_next_shake()
