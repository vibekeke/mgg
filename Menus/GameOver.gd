extends Control

var level_to_retry = null

func _ready():
	$CanvasLayer/VBoxContainer/RetryButton.grab_focus()

func _on_RetryButton_pressed():
	get_tree().change_scene("res://ActionLevels/Level1/Level1_Forest.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
