extends Node2D

onready var animation_player = get_node("%AnimationPlayer")
onready var text_appear_animation_player = get_node("%TextAppear")
onready var os_title = get_node("%OSTitle")
var looped_once := false

func _ready():
	animation_player.play("spin")


func animation_looped_first():
	if !looped_once:
		text_appear_animation_player.play("text_appear")
		looped_once = true
