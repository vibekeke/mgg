extends PathFollow2D

onready var visibility_notifier = $VisibilityNotifier2D
export(float) var speed := 500

func set_speed(speed):
	self.speed = speed

func _process(delta):
	if off_leftside_screen():
		self.queue_free()
	self.offset += speed * delta

func off_leftside_screen():
	return self.global_position.x < 0 || self.global_position.y < 0
	
