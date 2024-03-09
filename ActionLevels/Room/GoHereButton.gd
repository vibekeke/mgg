extends Panel

onready var can_create_dialogue = get_node("%CanCreateDialogueGoHere")
export var dialogue_resource : Resource
export var dialogue_title := "go_here_button_forest"

func _ready():
	self.connect("gui_input", self, "_on_gui_input")
	

func _on_gui_input(event: InputEvent):
	print("ye", event)
	if event is InputEventMouseButton and event.pressed:
		print("yeeee")
		if event.button_index == BUTTON_LEFT:
			print("buddy")
			can_create_dialogue.display_dialogue()

