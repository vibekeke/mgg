extends Node2D

@export var scroll_speed: int

@onready var area2d = $Area2D
var time = 0

func _ready():
	area2d.connect("body_entered", Callable(self, "_on_call_body_entered"))

func _increment_hearts():
	Events.emit_signal("collected_heart")

func _on_call_body_entered(body):
	if body.name == "Player":
		AudioManager.play_random_pitch("collect_heart", 0.03, -3.0)
		self.visible = false
		_increment_hearts()
		queue_free()

func _physics_process(delta):
	self.position.x -= scroll_speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
