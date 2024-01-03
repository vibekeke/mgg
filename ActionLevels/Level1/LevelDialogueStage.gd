extends Node2D

onready var animation_player = get_node("%AnimationPlayer")
onready var new_misbeehave = get_node("%NewMisbeehave")
onready var scene_transition_animation = get_node("%SceneTransitionAnimation")

func _ready():
	scene_transition_animation.connect("animation_finished", self, "_on_intro_animation_finished")
	#Events._disable_player_actions(0)
	Events.emit_signal("in_battle_dialogue", true)
	new_misbeehave.start_enemy_dialogue()

func _on_intro_animation_finished():
	animation_player.play("start_spotlight")
