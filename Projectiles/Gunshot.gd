extends AnimatedSprite

export var speed = 200
export var move_rightward = true
export var belongs_to_player = true
export var is_queue_freeable = true

enum ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var enum_map = { 0: ANGLE.FORWARD_B, 1: ANGLE.UPWARD_B, 2: ANGLE.DOWNWARD_B }

var angle_map = { ANGLE.FORWARD_B: 0, ANGLE.UPWARD_B: -30, ANGLE.DOWNWARD_B: -330 }

var bullet_type = ANGLE.FORWARD_B

func _ready():
	self.playing = true
	if belongs_to_player == false:
		var area2d = $EnemyGunshotArea2D
		if area2d != null:
			area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_area_entered(area):
	# hit area 2d = player melee attack wow strings are bad
	if area.is_in_group("player_hurtbox"):
		Events.emit_signal("collided_with_player", 1)
		self.queue_free()
	if area.name == "HitArea2D":
		belongs_to_player = true
		move_rightward = true
		speed = speed * 1.10

func num_to_enum(number):
	return enum_map.get(number, ANGLE.FORWARD_B)

func set_bullet_type(angle):
	bullet_type = num_to_enum(angle)
	self.rotate(deg2rad(angle_map[bullet_type]))

func _physics_process(delta):
	var movement_speed = speed * 10 * delta
	if move_rightward == false:
		movement_speed = movement_speed * -1
	if bullet_type == ANGLE.FORWARD_B:
		position += Vector2(movement_speed, 0)
	elif bullet_type == ANGLE.UPWARD_B:
		var radian = deg2rad(abs(angle_map[bullet_type]))
		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))
	elif bullet_type == ANGLE.DOWNWARD_B:
		var radian = deg2rad(abs(angle_map[bullet_type]))
		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	self.queue_free()
