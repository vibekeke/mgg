extends Node

class_name OurGuy
onready var parent_node = self.get_parent()
export var custom_grounded_spawn_point = Vector2(2005, 912)
export var speed_up_value = 300
var player_position
var current_health_value 

func _ready():
	Events.connect("player_global_position", self, "_on_player_global_position")
	Events.connect("enemy_taken_damage", self, "_on_taken_damage")
	current_health_value = parent_node.health_value

func _on_player_global_position(player_global_position):
	player_position = player_global_position

func get_spawn_height():
	return DataClasses.SpawnHeight.GROUND_ONLY

func get_custom_grounded_spawn_point():
	return self.custom_grounded_spawn_point

func _on_taken_damage(enemy, health_value):
	if parent_node == enemy:
		parent_node.initial_scroll_speed += speed_up_value

func _physics_process(delta):
	parent_node.position.x -= parent_node.initial_scroll_speed * delta

func get_class():
	return self.name
