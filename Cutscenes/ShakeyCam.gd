extends Node

@export var shake_intensity: float = 15.0
@export var rotation_intensity: float = 0.01
@export var shake_duration_min: float = 1.5
@export var shake_duration_max: float = 3.0

var camera: Camera2D
var tween: Tween
var base_position: Vector2
var base_rotation: float

func _ready():
	camera = get_parent()
	base_position = camera.position
	base_rotation = camera.rotation
	start_next_shake()

func start_next_shake():
	var duration = randf_range(shake_duration_min, shake_duration_max)
	var target_offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	var target_rotation = base_rotation + randf_range(-rotation_intensity, rotation_intensity)

	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "position", base_position + target_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "rotation", target_rotation, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_shake_complete)

func _on_shake_complete():
	start_next_shake()
