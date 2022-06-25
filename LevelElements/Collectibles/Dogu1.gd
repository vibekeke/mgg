extends Node2D

export (float, 1, 1000) var amplitude := 5.0
export (float, 1, 1000) var frequency := 150.0
var time = 0

func _ready():
	pass
	
func _physics_process(delta):
	time += delta
	var movement = cos(time * frequency) * amplitude
	$Area2D/AnimatedSprite.position.y += movement * delta
