extends Control

onready var mouse_click_audio = get_node("%MouseClick")

func _ready():
	pass
	
func _on_Desktop_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			mouse_click_audio.play()
