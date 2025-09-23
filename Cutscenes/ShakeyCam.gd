extends Node

export var shake_intensity: float = 15.0
export var rotation_intensity: float = 0.01
export var shake_duration_min: float = 1.5
export var shake_duration_max: float = 3.0

var camera: Camera2D
# var tween: Tween  # Commented out for Godot 4 compatibility
var tween: SceneTreeTween  # New Godot 4 tween
var base_position: Vector2
var base_rotation: float

func _ready():
	camera = get_parent()
	base_position = camera.position
	base_rotation = camera.rotation
	# Old tween code commented out for Godot 4 compatibility:
	# tween = Tween.new()
	# add_child(tween)
	# tween.connect("tween_all_completed", self, "_on_shake_complete")

	# Initialize first tween in start_next_shake()
	start_next_shake()

func start_next_shake():
	var duration = rand_range(shake_duration_min, shake_duration_max)
	var target_offset = Vector2(
		rand_range(-shake_intensity, shake_intensity),
		rand_range(-shake_intensity, shake_intensity)
	)
	var target_rotation = base_rotation + rand_range(-rotation_intensity, rotation_intensity)

	# Old tween code commented out for Godot 4 compatibility:
	# tween.interpolate_property(camera, "position",
	# 	camera.position, base_position + target_offset,
	# 	duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	# tween.interpolate_property(camera, "rotation",
	# 	camera.rotation, target_rotation,
	# 	duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	# tween.start()

	# New Godot 4 tween:
	tween = get_tree().create_tween()
	tween.set_parallel(true)  # Allow parallel tweening of multiple properties
	tween.tween_property(camera, "position", base_position + target_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "rotation", target_rotation, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", self, "_on_shake_complete")

func _on_shake_complete():
	start_next_shake()
