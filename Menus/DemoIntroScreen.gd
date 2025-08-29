extends Node2D

onready var animation_player = $AnimationPlayer
onready var audio_player = $AudioStreamPlayer

var pop_in_sfx = preload("res://sounds/computer/maximize_008.wav")
var click_sfx = preload("res://sounds/mouseclick-cut.mp3")

func _ready():
	animation_player.play("pop_in")
	


func _on_Button_pressed():
	audio_player.stream = click_sfx
	audio_player.play()
	Events.emit_signal("transition_to_scene", "TitleScreen")

func pop_in_sound():
	audio_player.stream = pop_in_sfx
	audio_player.play()
