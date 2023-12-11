extends Sprite

export var enabled : bool = true

var totalTime = 0.0
export var frequency : float = 0.5
export var amplitude : float = 0.5

func _physics_process(delta):
	totalTime += delta
	var new_y = self.global_position.y + sin(totalTime * frequency) * amplitude
	self.global_position.y = new_y
