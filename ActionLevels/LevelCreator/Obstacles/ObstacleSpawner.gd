extends Node2D

var basic_floating_platform = preload("res://ActionLevels/LevelCreator/Obstacles/FloatingPlatform.tscn")	

func spawn_level(level_name):
	if level_name == "Level1":
		var basic_floating_platform_node_1 = basic_floating_platform.instance()
		basic_floating_platform_node_1.scroll_speed = 500
		var basic_floating_platform_node_2 = basic_floating_platform.instance()
		basic_floating_platform_node_2.scroll_speed = 500
		basic_floating_platform_node_2.position.x -= 500
		add_child(basic_floating_platform_node_1)
		add_child(basic_floating_platform_node_2)
	
