extends Node2D

export var rotation_speed = PI

const TIME_PERIOD = 2
var time = 0

func _process(delta):
	time += delta
	$Sprite.self_modulate.a = 0
	$Sprite/Pivot.rotation += rotation_speed * delta
	$Sprite/Pivot/Sprite2.global_rotation = 0
	$Sprite/Pivot/Sprite3.global_rotation = 0
	$Sprite/Pivot/Sprite4.global_rotation = 0
	$Sprite/Pivot/Sprite5.global_rotation = 0
	$Sprite/Pivot/Sprite6.global_rotation = 0
	$Sprite/Pivot/Sprite7.global_rotation = 0
	$Sprite/Pivot/Sprite8.global_rotation = 0
	$Sprite/Pivot.modulate.a = ($Sprite/Pivot.modulate.a - (1 * delta))
	if time > TIME_PERIOD:
		self.queue_free()
