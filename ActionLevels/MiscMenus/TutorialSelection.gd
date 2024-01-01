extends Control

export var title := ""
export var dialogue : Resource

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	MggDialogue.create_dialogue_balloon(title, dialogue, self.get_parent().get_instance_id()) 

func _on_dialogue_box_finished(node_id: int):
	if self.get_instance_id() == node_id:
		print("dialogue finished")
