extends Control

signal scene_change_requested(next_scene)

export (String, FILE, "*.tscn") var next_scene

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		print("do do do")
		emit_signal("scene_change_requested", next_scene)
