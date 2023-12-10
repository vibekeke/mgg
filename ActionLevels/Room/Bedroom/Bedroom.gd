extends Node2D

onready var overworld_player = get_node("%OverworldPlayer")
onready var computer_screen_2d = get_node("%ComputerScreen2D")

func _ready():
	computer_screen_2d.connect("screen_open", self, "_on_screen_open")


func _on_screen_open(status):
	if status:
		overworld_player.is_controlled = true
	else:
		overworld_player.is_controlled = false
