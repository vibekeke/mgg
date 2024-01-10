extends Node2D

var title = "level_test"

func _ready():
	Events.emit_signal("enemy_spawner_enabled", false)
