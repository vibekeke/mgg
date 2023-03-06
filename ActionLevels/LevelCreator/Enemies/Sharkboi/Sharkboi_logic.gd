extends Node

class_name Sharkboi
onready var parent_node = self.get_parent()
export (float, 1, 1000) var amplitude := 15.0
export (float, 1, 1000) var frequency := 150.0
var time = 0

func get_default_speed():
	return 500

func _physics_process(delta):
	time += delta
	var movement = cos(time * frequency) * amplitude
	parent_node.position.y += movement * delta
	parent_node.position.x -= parent_node.initial_scroll_speed * 1.50 * delta
