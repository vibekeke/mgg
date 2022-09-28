extends Node2D

export (int) var scroll_speed

onready var area2d = $Area2D
var time = 0

func _ready():
	area2d.connect("body_entered", self, "_on_call_body_entered")

func _increment_stars():
	print("collected star")
	Events.emit_signal("collected_star")

func _on_call_body_entered(body):
	if body.name == "Player":
		self.visible = false
		_increment_stars()
		queue_free()

func _physics_process(delta):
	self.position.x -= scroll_speed * delta
