class_name GenericPlatform
extends Node2D

@export var scroll_speed: int

func _process(delta):
	self.position.x -= scroll_speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	Events.emit_signal("platform_return_to_pool", self)
