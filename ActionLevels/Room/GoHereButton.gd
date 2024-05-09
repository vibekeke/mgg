extends Panel

onready var can_create_dialogue = get_node("%CanCreateDialogueGoHere")

func _ready():
	self.connect("gui_input", self, "_on_gui_input")
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			can_create_dialogue.display_dialogue()

func _on_mouse_entered():
	print("mouse entered")

func _on_mouse_exited():
	print("mouse exited")
