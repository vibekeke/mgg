extends Node2D
export (String, FILE, "*.tscn") var target_scene # the default scene the scene manager should change to

	
func _ready():
	_load_initial_scene()

func _load_initial_scene(_next_scene := target_scene) -> void:
	var _next_scene_instance = load(_next_scene).instance()
	self.add_child(_next_scene_instance)
