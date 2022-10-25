extends AnimatedSprite

var scroll_speed = 500

func _physics_process(delta):
	self.position.x += scroll_speed * 1.50 * delta
	if global_position.x > 2800:
		self.queue_free()
