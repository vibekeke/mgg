extends CanvasLayer

onready var scene_transition_animation_player = get_node("%SceneTransitionAnimationPlayer")
var bars_move_right_played_forward = false

signal animation_finished

func _ready():
	start_stage_intro()

func start_stage_intro():
	scene_transition_animation_player.play("bars_move_right")

func _on_SceneTransitionAnimationPlayer_animation_finished(anim_name):
	print("anim name ", anim_name, "bars moved=", bars_move_right_played_forward)
	if anim_name == "bars_move_right" and !bars_move_right_played_forward:
		bars_move_right_played_forward = true
		yield(get_tree().create_timer(1.0), "timeout")
		scene_transition_animation_player.play("text_typeout")
	elif anim_name == "text_typeout":
		scene_transition_animation_player.play("text_flash")
	elif anim_name == "text_flash":
		yield(get_tree().create_timer(1.0), "timeout")
		scene_transition_animation_player.play_backwards("bars_move_right")
	elif anim_name == "bars_move_right" and bars_move_right_played_forward:
		emit_signal("animation_finished")
