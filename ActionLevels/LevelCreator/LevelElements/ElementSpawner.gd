extends Node2D

onready var base_collectible = preload("res://ActionLevels/LevelCreator/LevelElements/Collectibles/Dogu1.tscn")
var total_instanced_elements = 0

func instance_default_for_level(level_name):
	if level_name == "Level1":
		var base_collectible_node = base_collectible.instance()
		base_collectible_node.scroll_speed = 500
		base_collectible_node.x_init = 1930
		base_collectible_node.y_init = 100
		add_child(base_collectible_node)
