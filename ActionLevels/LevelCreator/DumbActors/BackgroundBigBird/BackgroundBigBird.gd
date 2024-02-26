extends Node2D

export var direction = 1
export var speed = 100
var is_moving := true

func _ready():
	Events.connect("in_battle_dialogue", self, "_on_in_battle_dialogue")
	MggDialogue.connect("dialogue_finished_with_status", self,"_on_dialogue_finished")

func _physics_process(delta):
	if is_moving:
		self.global_position.x += (speed * direction) * delta

func _on_in_battle_dialogue(in_battle_dialogue, enemy_name):
	is_moving = false

func _on_dialogue_finished(dialogue_finished):
	is_moving = true
