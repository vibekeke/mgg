extends Sprite2D

@export var enabled : bool = true

var totalTime = 0.0
@export var frequency : float = 2
@export var amplitude : float = 3

func _physics_process(delta):
	totalTime += delta
	var new_y = self.global_position.y + sin(totalTime * frequency) * amplitude
	self.global_position.y = new_y
