extends Node2D

onready var talking_trigger = get_node("%IsTalkingEnemy")
onready var can_move_single_direction = get_node("%CanMoveSingleDirection")

export var talks := false
export var moving := true

func _ready():
	can_move_single_direction.is_moving = false
	talking_trigger.trigger_dialogue()
	
func _process(delta):
	pass
