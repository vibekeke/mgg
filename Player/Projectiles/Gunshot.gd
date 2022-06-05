extends AnimatedSprite

export var speed = 200

var timer = 0
var direction = 0

func _ready():
	self.playing = true
	
func _process(delta):
	timer += delta
	
#	if timer > 0.5:
#		queue_free() ## kill
	
	position += Vector2(speed * 10 * delta, 0)
