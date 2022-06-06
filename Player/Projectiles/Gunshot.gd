extends AnimatedSprite

export var speed = 200

enum ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var enum_map = { 0: ANGLE.FORWARD_B, 1: ANGLE.UPWARD_B, 2: ANGLE.DOWNWARD_B }

var angle_map = { ANGLE.FORWARD_B: 0, ANGLE.UPWARD_B: -30, ANGLE.DOWNWARD_B: -330 }

var timer = 0
var direction = 0
var bullet_type = ANGLE.FORWARD_B

func _ready():
	self.playing = true

func num_to_enum(number):
	return enum_map.get(number, ANGLE.FORWARD_B)

func set_bullet_type(angle):
	bullet_type = num_to_enum(angle)
	self.rotate(deg2rad(angle_map[bullet_type]))

func _process(delta):
	timer += delta
	
#	if timer > 0.5:
#		queue_free() ## kill
	var movement_speed = speed * 10 * delta
	if bullet_type == ANGLE.FORWARD_B:
		position += Vector2(movement_speed, 0)
	elif bullet_type == ANGLE.UPWARD_B:
		var radian = deg2rad(abs(angle_map[bullet_type]))
		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))
	elif bullet_type == ANGLE.DOWNWARD_B:
		var radian = deg2rad(abs(angle_map[bullet_type]))
		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))
