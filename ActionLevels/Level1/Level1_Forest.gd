extends Node2D

onready var spawn_paths = $SpawnPaths

func _ready():
	var num_spawn_points = spawn_paths.get_curve().get_point_count()
	var spawn_point_array = []
	for x in range(0, num_spawn_points):
		spawn_point_array.append(spawn_paths.get_curve().get_point_position(x))
	Events.emit_signal("level_spawn_points", spawn_point_array)
