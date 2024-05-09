extends Node2D

onready var computer_screen = get_node("%ComputerScreen")

func toggle_screen(toggle: bool):
	computer_screen.visible = toggle

