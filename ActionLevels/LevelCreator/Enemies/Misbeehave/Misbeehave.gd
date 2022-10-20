extends Node

class_name Misbeehave
onready var parent_node = self.get_parent()

func _physics_process(delta):
	parent_node.position.x -= parent_node.initial_scroll_speed * 1.50 * delta

func get_default_speed():
	return 500

func get_class():
	return "Misbeehave"
