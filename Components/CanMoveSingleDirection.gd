extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)
export var speed := 500
var is_moving := true
var direction := 1

func _physics_process(delta):
	if is_moving:
		enemy_node.global_position.x -= (speed * direction) * delta
