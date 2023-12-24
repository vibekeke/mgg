extends Sprite

var player_in_area : bool = false
var dialogue_open : bool = false

onready var dialog_box = get_node("%TestDialogueCreator")

func _ready():
	dialog_box.connect("dialogue_box_finished", self, "_on_dialogue_box_finished")

func _on_InteractableArea_body_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true

func _on_InteractableArea_body_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func display_dialogue():
	dialog_box.create_dialogue_balloon()
	dialogue_open = true
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player_in_area and !dialogue_open:
		print("display dialogue")
		display_dialogue()

func _on_dialogue_box_finished():
	print("dialogue box finished")
	dialogue_open = false
