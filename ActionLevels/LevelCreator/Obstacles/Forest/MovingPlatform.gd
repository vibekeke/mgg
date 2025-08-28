extends MeshInstance2D

export (int) var scroll_speed
var platform_visibility_notifier = VisibilityNotifier2D.new()

func _process(delta):
	self.position.x -= scroll_speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	Events.emit_signal("platform_return_to_pool", self)
