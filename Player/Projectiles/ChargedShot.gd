extends AnimatedSprite

export var belongs_to_player : bool = true
export var is_queue_freeable : bool = false
export var shot_duration : float = 1.75
var player_position = null
onready var shoot_duration_timer = Timer.new()
onready var flash_collision_shape_timer = Timer.new()

onready var collision_shape_extents = {
	0: Vector2.ZERO,
	1: Vector2.ZERO,
	2: Vector2.ZERO,
	3: Vector2.ZERO,
	4: Vector2(1069, 22),
	5: Vector2(1069, 85),
	6: Vector2(1069, 85),
	7: Vector2(1069, 85),
	8: Vector2(1069, 85),
	9: Vector2(1069, 85),
	10: Vector2(1069, 85),
	11: Vector2(1069, 17),
	12: Vector2.ZERO,
	13: Vector2.ZERO,
	14: Vector2.ZERO,
	15: Vector2.ZERO
}

func _ready():
	shoot_duration_timer.set_name("charge_shot_duration_timer")
	shoot_duration_timer.connect("timeout", self, "_on_shoot_duration_timeout")
	shoot_duration_timer.set_wait_time(shot_duration)
	self.add_child(shoot_duration_timer)
	flash_collision_shape_timer.set_name("flash_collision_shape_timer")
	flash_collision_shape_timer.connect("timeout", self, "_on_flash_collision_shape_timeout")
	flash_collision_shape_timer.set_wait_time(0.35)
	self.add_child(flash_collision_shape_timer)
	self.playing = true
	self.frame = 0
	Events.connect("player_global_position", self, "_on_player_global_position")
	shoot_duration_timer.start()
	flash_collision_shape_timer.start()

func expand_collision_shape(frame: int):
	var new_collision_shape_extent = collision_shape_extents[frame]
	$Area2D/CollisionShape2D.shape.extents = new_collision_shape_extent

func _on_player_global_position(player_global_position):
	player_position = player_global_position

func _process(delta):
	if self.animation == "default" and self.frame >= 7 and !shoot_duration_timer.is_stopped():
		self.animation = "shoot_loop"
		self.speed_scale = 2.0
	if self.animation == "shoot_loop" and self.frame >= 2:
		self.frame = 0

func _physics_process(delta):
	if self.animation == "default":
		expand_collision_shape(self.frame)
	if self.animation == "shoot_loop":
		$Area2D/CollisionShape2D.shape.extents = collision_shape_extents[7]
	if player_position != null:
		self.global_position.x = player_position.x + 1200
		self.global_position.y = player_position.y + 2

func _on_flash_collision_shape_timeout():
	$Area2D/CollisionShape2D.disabled = !$Area2D/CollisionShape2D.disabled

func _on_shoot_duration_timeout():
	self.animation = "default"
	self.frame = 7
	shoot_duration_timer.stop()

func _on_ChargedShot_animation_finished():
	self.queue_free()
