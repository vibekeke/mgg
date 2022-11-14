extends Node2D
# should just hurt the player and not much else, not special or deflectable

export (float) var speed = 100

onready var area2d = $Projectile/Area2D
onready var visual_body = $VisualStar

func off_leftside_screen():
	return self.global_position.x < 0 || self.global_position.y < 0

func _process(delta):
	self.position += self.transform.x * speed * delta
	self.visual_body.set_global_rotation(0)
	if off_leftside_screen():
		self.queue_free()

func _ready():
	if area2d != null:
		area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		Events.emit_signal("collided_with_player", 1)


func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
