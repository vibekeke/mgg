extends Control

export (PackedScene) var root_scene

func _ready():
	$CanvasLayer/OptionsMenu/BackButton.connect("pressed", self, "_on_BackButton_pressed")
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionButton.connect("pressed", self, "_on_ResolutionButton_pressed")
	$CanvasLayer/VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://ActionLevels/RootLevel.tscn")


func _on_OptionsButton_pressed():
	$CanvasLayer/VBoxContainer.visible = false
	$CanvasLayer/OptionsMenu.visible = true
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionButton.grab_focus()

func _on_BackButton_pressed():
	$CanvasLayer/OptionsMenu.visible = false
	$CanvasLayer/VBoxContainer.visible = true
	$CanvasLayer/VBoxContainer/StartButton.grab_focus()

func _on_ResolutionButton_pressed():
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionList.visible = true
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionList.grab_focus()

func _on_QuitButton_pressed():
	get_tree().quit()
