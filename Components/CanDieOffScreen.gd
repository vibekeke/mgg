extends Node

@export var enemy: NodePath
@onready var enemy_node = get_node(enemy)

@export var visibility_notifier: NodePath
@onready var visibility_notifier_node = get_node(visibility_notifier)

func _ready():
	visibility_notifier_node.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _on_screen_exited():
	if is_instance_valid(enemy_node) && enemy_node.global_position.x <= 0:
			enemy_node.queue_free()
