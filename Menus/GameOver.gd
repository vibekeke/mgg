extends Control


func _ready():
	$CanvasLayer/VBoxContainer/RetryButton.grab_focus()

func _on_RetryButton_pressed():
	print("This doesnt do anything yet, my bad.")

func _on_QuitButton_pressed():
	get_tree().quit()
