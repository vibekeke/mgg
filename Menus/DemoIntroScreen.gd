extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("pop_in")


func _on_Button_pressed():
	Events.emit_signal("transition_to_scene", "TitleScreen")
