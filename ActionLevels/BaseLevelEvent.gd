class_name BaseLevelEvent extends Node2D

export var time_until_event := 30
export (NodePath) var root_level_node_path
export (NodePath) var enemy_spawner_node_path

onready var root_level_node = get_node_or_null(root_level_node_path)
onready var enemy_spawner_node = get_node_or_null(enemy_spawner_node_path)

func pause_level():
	pass
