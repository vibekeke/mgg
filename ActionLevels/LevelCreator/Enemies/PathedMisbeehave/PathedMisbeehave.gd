extends Node

class_name PathedMisbeehave
@onready var parent_node = self.get_parent()
@onready var path2d : Path2D = parent_node.get_node_or_null("Path2D")
@onready var path_follow : PathFollow2D = path2d.get_node_or_null("PathFollow2D")

#onready var default_speed = parent_node.initial_scroll_speed
var default_speed = 300

func _physics_process(delta):
	# if reached end of path just move as normal
	if path_follow.get_progress_ratio() >= 1:
		parent_node.position.x -= get_default_speed() * 1.50 * delta
	else: 
		path_follow.set_progress(path_follow.get_progress() + get_default_speed() * 1.5 * delta)
	
func get_default_speed():
	return default_speed
	
func set_default_speed(speed: int):
	default_speed = speed

func get_enemy_class():
	return "PathedMisbeehave"
