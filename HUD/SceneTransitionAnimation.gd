extends CanvasLayer

onready var scene_transition_animation_player = get_node("%SceneTransitionAnimationPlayer")
onready var title = get_node("%Title")

var current_enemy_name = ""

signal animation_finished
signal before_bars_move_up(enemy_name)

func _ready():
	current_enemy_name = ""
	Events.connect("in_battle_dialogue", self, "_on_in_battle_dialogue")

func set_dialogue_success():
	title.bbcode_text = "DIALOGUE SUCCESS!!!"

func set_dialogue_failure():
	title.bbcode_text = "DIALOGUE FAILED..."

func _on_in_battle_dialogue(status, enemy_name):
	if status:
		current_enemy_name = enemy_name
		start_stage_intro()

func start_stage_intro():
	self.visible = true
	scene_transition_animation_player.play("bars_move_right")

func end_stage(dialogue_status):
	print("ending stage")
	if dialogue_status:
		set_dialogue_success()
	else:
		set_dialogue_failure()
	print("play something")
	scene_transition_animation_player.play("bars_move_right")
	

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
