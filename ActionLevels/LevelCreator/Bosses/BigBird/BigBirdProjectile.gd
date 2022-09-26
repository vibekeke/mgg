extends Node2D
# should just hurt the player and not much else, not special or deflectable

export (float) var speed = 100

onready var main_body = $LilBird
onready var area2d = $LilBird/Area2D
onready var visual_body = $LilBird2

func off_leftside_screen():
	return self.global_position.x < 0 || self.global_position.y < 0

func _process(delta):
	self.position += self.transform.x * speed * delta
	self.visual_body.set_global_rotation(0)
	if off_leftside_screen():
		self.queue_free()

func _ready():
	if area2d != null:
		area2d.connect("body_entered", self, "_on_call_body_entered")
		area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_body_entered(body):
	if body.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)

func _on_call_area_entered(area):
	if area.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)


func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
