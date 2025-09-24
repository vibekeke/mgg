extends Node

@export var enemy: NodePath
@onready var enemy_node = get_node(enemy)
@export var title := ""
@export var dialogue : Resource

@export var placement # (DataClasses.Placement)

@export var can_take_damage: NodePath
@onready var can_take_damage_node = get_node(can_take_damage)

@export var touch_damage: NodePath
@onready var touch_damage_node = get_node(touch_damage)


@onready var screen_size = get_viewport().get_visible_rect().size
@onready var middle_of_screen = screen_size.x / 2.0

@export var movement_component: NodePath
@onready var movement_component_node = get_node(movement_component)

@export var tegn_mark: NodePath
@onready var tegn_mark_node = get_node(tegn_mark)

@export var enemy_name = ""
@export var tegn_mark_position := Vector2.ZERO

var dialogue_triggered := false

func set_dialogue(_title, dialogue_resource, dialogue_placement, enemy_name):
	self.title = _title
	self.dialogue = dialogue_resource
	placement = dialogue_placement
	enemy_name = enemy_name

func _ready():
	if is_instance_valid(tegn_mark_node):
		tegn_mark_node.visible = true
	Events.connect("dialogue_intro_finished", Callable(self, "_on_dialogue_intro_finished"))
	can_take_damage_node.damage_disabled = true
	touch_damage_node.is_disabled = true
	MggDialogue.connect("mgg_dialogue_box_finished", Callable(self, "_on_dialogue_box_finished"))

func _physics_process(delta):
	if enemy_node.global_position.x < middle_of_screen and !dialogue_triggered:
		trigger_dialogue()

func trigger_dialogue():
	if is_instance_valid(tegn_mark_node):
		tegn_mark_node.visible = false
	dialogue_triggered = true
	if movement_component_node != null and "is_moving" in movement_component_node:
		movement_component_node.is_moving = false
	Events.emit_signal("in_battle_dialogue", true, enemy_name)

func _on_dialogue_intro_finished():
	print("making dialogue")
	MggDialogue.create_dialogue_balloon(title, dialogue, enemy_node.get_instance_id(), placement) 


func _on_dialogue_box_finished(node_id: int):
	print("dialogue box finished", node_id)
