extends MeshInstance2D

export (int) var scroll_speed
var platform_visibility_notifier = VisibilityNotifier2D.new()

func _physics_process(delta):
	self.position.x -= scroll_speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
