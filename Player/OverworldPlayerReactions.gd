extends Node2D

onready var animation_player = get_node("%AnimationPlayer")
onready var question_mark = get_node("%QuestionMark")
var playing_backwards = false

func _ready():
	pass

func play_question_mark():
	playing_backwards = false
	question_mark.visible = true
	animation_player.play("reaction_appear")
	
func remove_question_mark():
	playing_backwards = true
	animation_player.play_backwards("reaction_appear")
	#question_mark.visible = false
	#animation_player.stop(true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "reaction_appear" and playing_backwards:
		question_mark.visible = false
