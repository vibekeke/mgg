extends Node

signal dialogue_box_finished

@export var title := ""
@export var dialogue_resource: DialogueResource
var dialogue_begun = false
var has_connected_signal = false
var enable_create_dialogue_balloon = true
@export var placement: int = DataClasses.Placement.LOWER
@export var character_portrait := DataClasses.CharacterPortrait.None # (DataClasses.CharacterPortrait)
@export var dialogue_box_colour := Color(0.12549, 0.619608, 1, 1)
@export var dialogue_border_colour := Color(0.0, 0.0, 0.0, 1.0)
var is_advancable := false
var auto_advance_time := 1.5

var dialogue_bubble = preload("res://DialogBox/DialogueContainer.tscn")

@onready var timer = get_node("%Timer")

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func create_dialogue_balloon():
	if enable_create_dialogue_balloon:
		show_dialogue(title)
	
func show_dialogue(key: String) -> void:
	var dialogue = await dialogue_resource.get_next_dialogue_line(key)
	if self.get_child_count() > 1:
		self.get_child(1).set_next_dialogue(dialogue)
	else:
		var new_dialogue_bubble = dialogue_bubble.instantiate()
		new_dialogue_bubble.placement = placement
		new_dialogue_bubble.character_portrait = character_portrait
		new_dialogue_bubble.dialogue_box_colour = dialogue_box_colour
		new_dialogue_bubble.is_advancable = is_advancable
		new_dialogue_bubble.auto_advance_time = auto_advance_time
		new_dialogue_bubble.set_dialogue(dialogue)
		self.add_child(new_dialogue_bubble)
	show_dialogue(await self.get_child(1).actioned)

func _on_dialogue_finished(resource: DialogueResource):
	enable_create_dialogue_balloon = false
	if self.get_child_count() > 1 and is_instance_valid(self.get_child(1)):
			self.get_child(1).queue_free()
	timer.start()

func _on_Timer_timeout():
	enable_create_dialogue_balloon = true
	emit_signal("dialogue_box_finished")
