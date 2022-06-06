extends Area2D

export (float, 1, 1000) var frequency = 10
export (float, 1000) var amplitude = 1000
var time = 0

func _ready():
	var playing = $Path2D/PathFollow2D/AnimatedSprite
	playing.playing = true

func _process(delta):
#	time += delta
#	var movement = sin(time * frequency) * amplitude
#	position.y += movement * delta
#	position.x -= 100 * delta
	$Path2D/PathFollow2D.offset += 85 * delta
