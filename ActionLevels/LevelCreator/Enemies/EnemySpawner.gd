extends Node2D

onready var base_enemy = preload("res://ActionLevels/LevelCreator/Enemies/BaseEnemy.tscn")
var total_instanced_enemies = 0

func instance_default_for_level(level_name):
	if level_name == "Level1":
		var base_enemy_node = base_enemy.instance()
		add_child(base_enemy_node)
