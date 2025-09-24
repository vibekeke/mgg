extends Control

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")
@onready var dog_collection : HBoxContainer = get_node("%DogCollection")
@onready var health : HBoxContainer = get_node("%Health")
@onready var crystal_container : HBoxContainer = get_node("%CrystalContainer")
@onready var score_tracker : MarginContainer = get_node("%ScoreTracker")

@export var hide_health : bool = false
@export var auto_start : bool = false
@export var hide_dogs : bool = false
@export var hide_crystal : bool = false
@export var hide_score : bool = false

func _ready():
	Events.connect("fall_down_ui", Callable(self, "_on_fall_down_ui"))
	Events.connect("go_up_ui", Callable(self, "_on_go_up_ui"))
	if hide_dogs:
		dog_collection.hide()
	if auto_start:
		_on_fall_down_ui()
	if hide_health:
		health.hide()
	if hide_crystal:
		crystal_container.hide()
	if hide_score:
		score_tracker.hide()

func _on_fall_down_ui():
	animation_player.play("fall_down")
	
func _on_go_up_ui():
	animation_player.play("go_up")
