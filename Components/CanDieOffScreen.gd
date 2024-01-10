extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)

export (NodePath) var visibility_notifier
onready var visibility_notifier_node = get_node(visibility_notifier)

func _ready():
	visibility_notifier_node.connect("screen_exited", self, "_on_screen_exited")

func _on_screen_exited():
	if is_instance_valid(enemy_node):
		if enemy_node.global_position.x <= 0:
			enemy_node.queue_free()
