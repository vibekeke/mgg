extends Node

signal mgg_dialogue_box_finished(node_id)
var node_id_in_use = -1
var current_dialogue_creator_node

func create_dialogue_balloon(title: String, dialogue_resource: Resource, node_id: int):
	var dialogue_creator = load("res://DialogBox/DialogueCreator.tscn").instance()
	dialogue_creator.title = title
	dialogue_creator.dialogue_resource =dialogue_resource
	dialogue_creator.connect("dialogue_box_finished", self, "_on_dialogue_box_finished")
	node_id_in_use = node_id
	get_tree().current_scene.add_child(dialogue_creator)
	dialogue_creator.create_dialogue_balloon()
	current_dialogue_creator_node = dialogue_creator

func _on_dialogue_box_finished():
	current_dialogue_creator_node.queue_free()
	yield(current_dialogue_creator_node, "tree_exited")
	emit_signal("mgg_dialogue_box_finished", node_id_in_use)
