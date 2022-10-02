extends Control

export (PackedScene) var root_scene

func _ready():
	$CanvasLayer/VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://ActionLevels/RootLevel.tscn")


func _on_OptionsButton_pressed():
	pass


func _on_QuitButton_pressed():
	get_tree().quit()
