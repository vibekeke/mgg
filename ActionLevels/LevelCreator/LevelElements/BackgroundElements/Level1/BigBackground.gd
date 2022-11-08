extends AnimatedSprite


var scroll_speed = 100

func _physics_process(delta):
	self.position.x += scroll_speed * delta
	if global_position.x > 2800:
		print("emitting background element offscreen big background")
		Events.emit_signal("background_element_offscreen", DataClasses.Enemies.BIG_BIRD)
		self.queue_free()
