extends Node2D

@export var dialogue_resource : DialogueResource
@export var dialogue_title : String

func create_dialogue():
	MggDialogue.create_dialogue_balloon(
			dialogue_title,
			dialogue_resource,
			self.get_instance_id(), 
			DataClasses.Placement.LOWER, 
			DataClasses.CharacterPortrait.AngelNeutral,
			Color(0.0, 0.42, 0.628, 0.5),
			Color(0.0, 0.0, 0.0, 0.25),
			false,
			3.0
		)

func _ready() -> void:
	create_dialogue()
