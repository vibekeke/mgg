extends Node

class_name BigBird

onready var parent_node = self.get_parent()

func _ready():
	pass


func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BigBird"
