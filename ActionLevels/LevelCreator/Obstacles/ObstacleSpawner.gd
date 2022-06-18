extends Node2D

var basic_floating_platform = preload("res://ActionLevels/LevelCreator/Obstacles/FloatingPlatform.tscn")	
var total_instanced_obstacles = 0
export (int) var default_obstacle_speed

	
func instance_default_for_level(level_name):
	if level_name == "Level1":
		print(get_viewport().size)
		var basic_floating_platform_node = basic_floating_platform.instance()
		basic_floating_platform_node.position.x = 1930 # do this smarterer later
		basic_floating_platform_node.position.y = 900 # do this smarterer later
		basic_floating_platform_node.scroll_speed = default_obstacle_speed
		add_child(basic_floating_platform_node)
