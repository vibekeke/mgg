extends Node2D
# should just hurt the player and not much else, not special or deflectable

export (float) var speed = 500.0

onready var area2d = $Projectile/Area2D
onready var visual_body = $Star
var player_position
var shoot_towards = false
var angle_to_player
var set_angle = false

func off_leftside_screen():
	return self.global_position.x < 0 || self.global_position.y < 0

func _physics_process(delta):
	self.visual_body.set_global_rotation(0)
	if off_leftside_screen():
		self.queue_free()
	if shoot_towards:
		go_towards_point(delta)

func go_towards_point(delta):
	if shoot_towards:
		if player_position != null:
			if !set_angle:
				angle_to_player = self.global_position.angle_to_point(player_position)
				set_angle = true
			self.global_position += Vector2(-(speed * delta * cos(angle_to_player)), -(speed * delta * sin(angle_to_player)))


func _ready():
	if area2d != null:
		area2d.connect("body_entered", self, "_on_call_body_entered")
		area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_body_entered(body):
	if body.name == 'Player':
		Events.emit_signal("collided_with_player", 1)

func _on_call_area_entered(area):
	if area.name == 'Player':
		Events.emit_signal("collided_with_player", 1)


func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
