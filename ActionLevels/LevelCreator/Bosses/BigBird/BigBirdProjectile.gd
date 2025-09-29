extends Node2D
# should just hurt the player and not much else, not special or deflectable

@export var speed: float = 100

@onready var area2d = $LilBird/Area2D
@onready var visual_body = $LilBird2
@onready var animation_player = get_node("%AnimationPlayer")

var is_invalid : bool = false

func off_leftside_screen():
	return self.global_position.x < 0 || self.global_position.y < 0

func _process(delta):
	self.position += self.transform.x * speed * delta
	self.visual_body.set_global_rotation(0)
	if off_leftside_screen():
		self.queue_free()

func _ready():
	Events.connect("pacifist_successful", Callable(self, "_on_pacifist_successful"))
	Events.connect("level_event_complete", Callable(self, "_on_level_event_complete"))
	if area2d != null:
		area2d.connect("area_entered", Callable(self, "_on_call_area_entered"))

func _on_pacifist_successful():
	animation_player.play("fade_out")

func _on_call_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		Events.emit_signal("collided_with_player", 1)

func _on_level_event_complete(event_name, event_number):
	if event_number == 6:
		animation_player.play("fade_out")

func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()
