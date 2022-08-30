extends KinematicBody2D

onready var _animation_player = $AnimatedSprite/AnimationPlayer
onready var _animation_tree = $AnimatedSprite/AnimationTree
onready var _anim_state = _animation_tree.get("parameters/playback")

const UP_DIRECTION := Vector2.UP

export var movementSpeed := 600.0
export var gravity := 2000.0
export var jump_power := 1200.0
export var add_jump_power: float = jump_power * 0.75
export var max_jumps := 2
export var max_health = 3

var current_health = max_health
var invul_timer = Timer.new()

# Private variables
var velocity := Vector2.ZERO
var normalized_velocity := Vector2.ZERO

var jumps_made := 0

enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var current_shooting_angle = SHOOT_ANGLE.FORWARD_B

export (PackedScene) var gunshot

func _ready():
	Events.connect("collided_with_player", self, "_on_collided_with_player")
	_animation_tree.active = true
	_anim_state.travel("Run")
	_invul_timer_setup()

func _invul_timer_setup():
	invul_timer.set_name("invul_timer")
	invul_timer.connect("timeout", self, "_on_invul_timeout")
	invul_timer.set_wait_time(0.5)
	self.add_child(invul_timer)

func _on_invul_timeout():
	print("timed out")
	modulate.a = 1
	invul_timer.stop()

func _physics_process(delta):
	var _horizontal_direction = (
		Input.get_action_strength("right") - Input.get_action_strength("left")
	)
	
	velocity.x = _horizontal_direction * movementSpeed
	normalized_velocity.x = clamp(velocity.x, -1, 1)
	velocity.y += gravity * delta
	normalized_velocity.y += clamp(velocity.y, -1, 1)
	
	
	var is_falling := velocity.y > 100.0 and not is_on_floor()
	var is_rising := velocity.y < 0.0 and not is_on_floor()
	var started_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var started_add_jump := Input.is_action_just_pressed("jump") and is_falling
	var has_jumped := false
	var is_not_moving := is_on_floor() and is_zero_approx(velocity.x)
	var is_moving := is_on_floor() and not is_zero_approx(velocity.x)

	shoot_staff()
	if started_jumping:
		jumps_made += 1
		_anim_state.travel("RisingLoop")
		velocity.y = -jump_power
	# TODO: Fix this hack using maths, e.g. store delta * gravity to help find peak of jump
	if is_rising and velocity.y > -1400:
		_anim_state.travel("AboutToFall")
	if is_falling:
		_anim_state.travel("FallingLoop")
	if _anim_state.get_current_node() == "FallingLoop" and (is_moving || is_not_moving) and not started_jumping:
		_anim_state.travel("Landing")
		jumps_made = 0
	
	velocity = move_and_slide(velocity, UP_DIRECTION)
	normalized_velocity.x = clamp(velocity.x, -1, 1)
	normalized_velocity.y = clamp(velocity.y, -1, 1)
	
func _process(delta):
	Events.emit_signal("player_max_health", max_health)
	Events.emit_signal("player_global_position", self.global_position)
	Events.emit_signal("player_local_position", self.position)

func shoot_staff():
	if Input.is_action_just_pressed("hold_test"):
		if current_shooting_angle == SHOOT_ANGLE.FORWARD_B:
			current_shooting_angle = SHOOT_ANGLE.UPWARD_B
		elif current_shooting_angle == SHOOT_ANGLE.UPWARD_B:
			current_shooting_angle = SHOOT_ANGLE.DOWNWARD_B
		elif current_shooting_angle == SHOOT_ANGLE.DOWNWARD_B:
			current_shooting_angle = SHOOT_ANGLE.FORWARD_B
		print(current_shooting_angle)
		
	if Input.is_action_just_pressed("shoot"):
		shoot(current_shooting_angle)

	
func shoot(angle):
	var _gunshot = gunshot.instance()
	_gunshot.set_bullet_type(angle)
	get_tree().get_root().add_child(_gunshot)
	_gunshot.position = self.position + Vector2(80,2)
	
func _on_collided_with_player(damage):
	if invul_timer.is_stopped():
		current_health = current_health - damage
		invul_timer.start()
		modulate.a = 0.5
		if current_health <= 0:
			Events.emit_signal("game_over")
		Events.emit_signal("player_damaged", damage)
