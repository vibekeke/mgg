extends AnimatedSprite

func _process(delta):
	if self.frame == 0:
		self.play("default", false)
	if self.frame == 7:
		self.play("default", true)
