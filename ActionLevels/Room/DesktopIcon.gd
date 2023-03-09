extends TextureRect


onready var chat_app = get_node("%ChatApp")

func _ready():
	pass

func click():
	chat_app.visible = !chat_app.visible
	

func _on_ChatIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			click()

