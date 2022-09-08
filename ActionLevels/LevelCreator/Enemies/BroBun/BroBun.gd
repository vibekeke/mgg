extends Node

class_name BroBun
onready var parent_node = self.get_parent()

onready var bunny_drop = false

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		if bunny_drop:
			parent_node.position.y += 500 * delta
		if parent_node.player_local_position != Vector2(0,0):
			if parent_node.position.x - parent_node.player_local_position.x > 0:
				var x_towards = parent_node.position.move_toward(parent_node.player_local_position, 500 * delta)
				if abs(parent_node.position.x - parent_node.player_local_position.x) < 100:
					bunny_drop = true
					parent_node.position.y += parent_node.initial_scroll_speed * 5 * delta
				parent_node.position.x = x_towards.x
			else:
				if bunny_drop == false:
					parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BroBun"
