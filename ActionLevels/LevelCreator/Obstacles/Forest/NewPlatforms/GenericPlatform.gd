class_name GenericPlatform
extends Node2D

export (int) var scroll_speed

func _process(delta):
	self.position.x -= scroll_speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	Events.emit_signal("platform_despawned")
	self.queue_free()
