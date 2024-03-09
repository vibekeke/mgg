extends Node

export var title := ""
export var dialogue : Resource
export(NodePath) var interactable_area
export var stop_player := true
export var trigger_from_node := false
export (DataClasses.CharacterPortrait) var initial_character_portrait = DataClasses.CharacterPortrait.None

signal created_dialogue_over

var player_in_area : bool = false
var dialogue_open : bool = false

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	var _interactable_area_node = get_node_or_null(interactable_area)
	if _interactable_area_node != null:
		_interactable_area_node.connect("body_entered", self, "_on_body_entered")
		_interactable_area_node.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func display_dialogue():
	if stop_player:
		Events.emit_signal("overworld_player_controlled", true)
	MggDialogue.create_dialogue_balloon(title, dialogue, self.get_parent().get_instance_id(), DataClasses.Placement.LOWER, initial_character_portrait) 
	dialogue_open = true

func _process(delta):
	if trigger_from_node:
		return
	if Input.is_action_just_pressed("ui_accept") and player_in_area and !dialogue_open:
		display_dialogue()

func _on_dialogue_box_finished(node_id: int):
	if self.get_parent().get_instance_id() == node_id:
		dialogue_open = false
		emit_signal("created_dialogue_over")
		if stop_player:
			Events.emit_signal("overworld_player_controlled", false)
