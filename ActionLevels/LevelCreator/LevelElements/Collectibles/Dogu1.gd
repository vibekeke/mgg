extends Node2D

export (float, 1, 1000) var amplitude := 5.0
export (float, 1, 1000) var frequency := 150.0
export (int) var scroll_speed
export (int) var y_init
export (int) var x_init

onready var area2d = $Area2D
var time = 0

func _ready():
	self.position.x = x_init
	self.position.y = y_init
	area2d.connect("body_entered", self, "_on_call_body_entered")

func _increment_dogs():
	print("send some kind of signal here")

func _on_call_body_entered(body):
	if body.name == "MPlayerTest":
		self.visible = false
		_increment_dogs()
		queue_free()

func _physics_process(delta):
	time += delta
	var movement = cos(time * frequency) * amplitude
	$Area2D/AnimatedSprite.position.y += movement * delta
	self.position.x -= scroll_speed * delta
