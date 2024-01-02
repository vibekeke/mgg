extends Node

signal dialogue_box_finished

export var title := ""
export var dialogue_resource: Resource
var dialogue_begun = false
var has_connected_signal = false
var enable_create_dialogue_balloon = true
export var placement: int = DataClasses.Placement.LOWER
onready var timer = get_node("%Timer")

func _ready():
	DialogueManager.connect("dialogue_finished", self, "_on_dialogue_finished")

func create_dialogue_balloon():
	if enable_create_dialogue_balloon:
		show_dialogue(title)
	
func show_dialogue(key: String) -> void:
	var dialogue = yield(dialogue_resource.get_next_dialogue_line(key), "completed")
	if self.get_child_count() > 1:
		self.get_child(1).set_next_dialogue(dialogue)
	else:
		var new_dialogue_bubble = load("res://DialogBox/DialogueContainer.tscn").instance()
		new_dialogue_bubble.placement = placement
		new_dialogue_bubble.set_dialogue(dialogue)
		self.add_child(new_dialogue_bubble)
	show_dialogue(yield(self.get_child(1), "actioned"))

# Signals

func _on_dialogue_finished():
	enable_create_dialogue_balloon = false
	if self.get_child_count() > 1 and is_instance_valid(self.get_child(1)):
			self.get_child(1).queue_free()
	timer.start()

func _on_Timer_timeout():
	enable_create_dialogue_balloon = true
	emit_signal("dialogue_box_finished")
