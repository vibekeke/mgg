extends Node2D

export (int) var scroll_speed

onready var area2d = $Area2D

func _ready():
	area2d.connect("body_entered", self, "_on_call_body_entered")

func _increment_stars():
	Events.emit_signal("collected_star")
	Events.emit_signal("score_popup_requested", "star", global_position)

func _on_call_body_entered(body):
	if body.name == "Player":
		AudioManager.play_random_pitch("collect_star", 0.04, -6.0)
		self.visible = false
		_increment_stars()
		queue_free()

func _physics_process(delta):
	self.position.x -= scroll_speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
