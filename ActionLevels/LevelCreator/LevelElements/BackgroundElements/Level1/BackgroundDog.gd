extends AnimatedSprite

var scroll_speed = 600

func _physics_process(delta):
	self.position.x += scroll_speed * delta
	if global_position.x > 2800:
		self.queue_free()
