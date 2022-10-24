extends Node

class_name SneakySnake
onready var parent_node = self.get_parent()
var player_position

func _ready():
	Events.connect("player_global_position", self, "_on_player_global_position")

func _on_player_global_position(player_global_position):
	player_position = player_global_position

func get_spawn_height():
	return DataClasses.SpawnHeight.GROUND_ONLY

func _physics_process(delta):
	parent_node.position.x -= parent_node.initial_scroll_speed * delta

func get_class():
	return self.name
