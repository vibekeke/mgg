extends Node

signal dialogue_finished

var title := ""
var dialogue_resource: Resource = null
	
func show_dialogue_balloon(dialogue_resource: Resource, dialogue_title: String):
	if dialogue_resource == null or dialogue_title == null:
		print("dialogue resource or dialogue title were null - resource = ", dialogue_resource, ", title = ", dialogue_title)
	self.dialogue_resource = dialogue_resource
	DialogueManager.connect("dialogue_finished", self, "_on_dialogue_finished")
	yield(get_tree().create_timer(0.4), "timeout")
	show_dialogue(dialogue_title)

func show_dialogue(key: String) -> void:
	var dialogue = yield(dialogue_resource.get_next_dialogue_line(key), "completed")
	if dialogue != null:
		var balloon = preload("res://DialogBox/portraits_balloon/portraits_balloon.tscn").instance()
		balloon.set_dialogue(dialogue)
		get_tree().current_scene.add_child(balloon)
		show_dialogue(yield(balloon, "actioned"))
		

# Signals

func _on_dialogue_finished():
	yield(get_tree().create_timer(0.4), "timeout")
	emit_signal("mgg_dialogue_finished")
	#get_tree().quit()
