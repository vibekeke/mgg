extends Node2D

export (String) var level_name

func _ready(): 
	$ObstacleSpawner.spawn_level(level_name)
	pass
