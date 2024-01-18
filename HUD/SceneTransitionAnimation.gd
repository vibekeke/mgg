extends CanvasLayer

onready var scene_transition_animation_player = get_node("%SceneTransitionAnimationPlayer")
onready var title = get_node("%Title")
onready var success_title = get_node("%SuccessTitle")
onready var failure_title = get_node("%FailureTitle")

var current_enemy_name = ""
var dialogue_over := false
var dialogue_success_status := false
signal animation_finished
signal before_bars_move_up(enemy_name)
signal dialogue_stage_finished

func _ready():
	current_enemy_name = ""
	Events.connect("in_battle_dialogue", self, "_on_in_battle_dialogue")
	MggDialogue.connect("dialogue_finished_with_status", self, "_on_dialogue_finished_with_status")

func _on_in_battle_dialogue(status, enemy_name):
	if status:
		current_enemy_name = enemy_name
		start_stage_intro()

func start_stage_intro():
	self.visible = true
	scene_transition_animation_player.play("bars_move_right")

func end_stage(success_status: bool):
	dialogue_success_status = success_status
	scene_transition_animation_player.play("stage_finished")

func _on_SceneTransitionAnimationPlayer_animation_finished(anim_name):
	if anim_name == "bars_move_right":
		yield(get_tree().create_timer(1.0), "timeout")
		scene_transition_animation_player.play("text_typeout")
	elif anim_name == "text_typeout":
		scene_transition_animation_player.play("text_flash")
	elif anim_name == "text_flash":
		yield(get_tree().create_timer(1.0), "timeout")
		emit_signal("before_bars_move_up", current_enemy_name)
		scene_transition_animation_player.play("bars_move_up")
	elif anim_name == "bars_move_up":
		emit_signal("animation_finished")
		yield(get_tree().create_timer(1.0), "timeout")
		Events.emit_signal("dialogue_intro_finished")
	elif anim_name == "stage_finished" && !dialogue_over:
		dialogue_over = true
		if dialogue_success_status:
			scene_transition_animation_player.play("success_text_typeout_finished")
		else:
			scene_transition_animation_player.play("failure_text_typeout_finished")
		pass
	elif anim_name == "success_text_typeout_finished":
		scene_transition_animation_player.play("success_text_flash_finished")
		emit_signal("dialogue_stage_finished")
		yield(get_tree().create_timer(1.0), "timeout")
		scene_transition_animation_player.play_backwards("stage_finished")
	elif anim_name == "failure_text_typeout_finished":
		scene_transition_animation_player.play("failure_text_flash_finished")
		emit_signal("dialogue_stage_finished")
		yield(get_tree().create_timer(1.0), "timeout")
		scene_transition_animation_player.play_backwards("stage_finished")

func _on_dialogue_finished_with_status(success_status: bool):
	print("ye buddy", success_status)
	dialogue_success_status = success_status
	end_stage(success_status)
