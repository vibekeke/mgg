extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)
export var title := ""
export var dialogue : Resource

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")

func trigger_dialogue():
	MggDialogue.create_dialogue_balloon(title, dialogue, enemy_node.get_instance_id()) 

func _on_dialogue_box_finished():
	print("dialogue box finished")
