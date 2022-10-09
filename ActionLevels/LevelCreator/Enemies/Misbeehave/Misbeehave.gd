extends Node

class_name Misbeehave
onready var parent_node = self.get_parent()

func _physics_process(delta):
	if parent_node != null:
		if !parent_node.is_move_disabled:
			if parent_node.player_global_position != Vector2(0,0) and parent_node.is_on_screen():
				if parent_node.position.x - parent_node.player_global_position.x > 0:
					parent_node.position = parent_node.position.move_toward(parent_node.player_global_position, parent_node.initial_scroll_speed * delta)
	parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_default_speed():
	return 500

func get_class():
	return "Misbeehave"
