extends Node2D
# should just hurt the player and not much else, not special or deflectable

var speed = 100.0
onready var area2d = $Projectile/Area2D
onready var visual_body = $Star
var player_position
var shoot_towards = false
var angle_to_player
var set_angle = false

func _physics_process(delta):
	self.visual_body.set_global_rotation(0)
	if shoot_towards:
		go_towards_point(delta)

func go_towards_point(delta):
	if shoot_towards && player_position != null:
		if !set_angle:
			angle_to_player = self.global_position.angle_to_point(player_position)
			set_angle = true
		self.global_position += Vector2(-(speed * delta * cos(angle_to_player)), -(speed * delta * sin(angle_to_player)))


func _ready():
	if area2d != null:
		area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		Events.emit_signal("collided_with_player", 1)
		self.queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	if self.global_position.y > 0:
		self.queue_free()

