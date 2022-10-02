extends Node2D
export (String, FILE, "*.tscn") var target_scene # the default scene the scene manager should change to

onready var game_over_screen = preload("res://Menus/GameOver.tscn")
	
func _ready():
	Events.connect("game_over", self, "_on_game_over")
	_load_initial_scene()

func _on_game_over():
	get_tree().change_scene("res://Menus/GameOver.tscn")

func _load_initial_scene(_next_scene := target_scene) -> void:
	var _next_scene_instance = load(_next_scene).instance()
	self.add_child(_next_scene_instance)
