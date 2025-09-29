extends Sprite2D

func _process(delta):
	self.rotate(delta * deg_to_rad(180.0))
