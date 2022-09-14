extends MeshInstance2D

export (int) var scroll_speed
	
func _physics_process(delta):
	self.position.x -= scroll_speed * delta
