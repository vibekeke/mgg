extends AnimatedSprite

var scroll_speed = 800

func _physics_process(delta):
	self.position.x += scroll_speed * delta
	if global_position.x > 2800:
		Events.emit_signal("background_element_offscreen", DataClasses.Enemies.OUR_GUY)
		self.queue_free()
