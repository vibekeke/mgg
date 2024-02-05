extends Node

signal mgg_dialogue_box_finished(node_id)
signal dialogue_finished_with_status(success_status)
signal change_character_portrait(portrait_name)
var node_id_in_use = -1
var current_dialogue_creator_node

func create_dialogue_balloon(title: String, dialogue_resource: Resource, node_id: int, placement: int = DataClasses.Placement.LOWER, initial_character_portrait := DataClasses.CharacterPortrait.None):
	var dialogue_creator = load("res://DialogBox/DialogueCreator.tscn").instance()
	dialogue_creator.title = title
	dialogue_creator.dialogue_resource = dialogue_resource
	dialogue_creator.placement = placement
	dialogue_creator.character_portrait = initial_character_portrait
	dialogue_creator.connect("dialogue_box_finished", self, "_on_dialogue_box_finished")
	node_id_in_use = node_id
	#get_tree().current_scene.add_child(dialogue_creator)
	get_tree().current_scene.call_deferred("add_child", dialogue_creator)
	dialogue_creator.create_dialogue_balloon()
	current_dialogue_creator_node = dialogue_creator

func _on_dialogue_box_finished():
	current_dialogue_creator_node.queue_free()
	yield(current_dialogue_creator_node, "tree_exited")
	emit_signal("mgg_dialogue_box_finished", node_id_in_use)

func go_to_scene(scene_name: String):
	print("going to scene ", scene_name)
	Events.transition_to_new_scene(scene_name)

func emit_dialogue_finished_with_status(success_status: bool):
	emit_signal("dialogue_finished_with_status", success_status)

func character_name_to_enum(portrait_name: String):
	return DataClasses.CharacterPortrait[portrait_name]

func emit_change_character_portrait(portrait_name: String):
	emit_signal("change_character_portrait", DataClasses.CharacterPortrait[portrait_name])
