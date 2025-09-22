extends Node2D

onready var animation_player = $AnimationPlayer
onready var audio_player = $AudioStreamPlayer


func _ready():
	animation_player.play("pop_in")
	$CanvasLayer/Window/TextureRect/Button.grab_focus()
	

func _on_Button_pressed():
	AudioManager.playSFX("mouse_click")
	Events.emit_signal("transition_to_scene", "TitleScreen", true)

func pop_in_sound():
	AudioManager.playSFX("ui_pop_in")


