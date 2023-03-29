extends Control

onready var mouse_click_audio = get_node("%MouseClick")

func _on_Desktop_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			mouse_click_audio.play()


func _on_StartButton_button_up():
	var pause_menu = get_node("%PauseMenu")
	pause_menu.set_is_paused(true)
