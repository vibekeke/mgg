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
export var fire_rate_secs := 0.15

var current_health = max_health
var invul_timer = Timer.new()
var fire_rate_timer = Timer.new()

var velocity := Vector2.ZERO
var normalized_velocity := Vector2.ZERO

var is_jump_disabled = false
var is_shoot_disabled = false
var is_move_disabled = false

var jumps_made := 0

enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }
var angle_map = { SHOOT_ANGLE.FORWARD_B: 0, SHOOT_ANGLE.UPWARD_B: -30, SHOOT_ANGLE.DOWNWARD_B: -330 }

var current_shooting_angle = SHOOT_ANGLE.FORWARD_B
onready var shooting_arrow_guide = $Arrow

export (PackedScene) var gunshot
export (PackedScene) var physical_attack

func _ready():
	Events.connect("collided_with_player", self, "_on_collided_with_player")
	Events.connect("disable_player_action", self, "_on_disable_player_action")
	Events.connect("transition_to_scene", self, "test")
	_animation_tree.active = true
	_anim_state.travel("Run")
	_invul_timer_setup()
	_fire_rate_timer_setup()

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	fire_rate_timer.set_wait_time(fire_rate_secs)
	self.add_child(fire_rate_timer)

func _invul_timer_setup():
	invul_timer.set_name("invul_timer")
	invul_timer.connect("timeout", self, "_on_invul_timeout")
	invul_timer.set_wait_time(0.5)
	self.add_child(invul_timer)

func _on_fire_rate_timeout():
	fire_rate_timer.stop()

func _on_invul_timeout():
	modulate.a = 1
	invul_timer.stop()

func move_arrow(angle):
	shooting_arrow_guide.rotate(deg2rad(angle_map[angle]))
#	if current_shooting_angle == SHOOT_ANGLE.FORWARD_B:
#		var radian = deg2rad()
#	elif current_shooting_angle == SHOOT_ANGLE.UPWARD_B:
#		var radian = deg2rad(abs(angle_map[current_shooting_angle]))
#		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))
#	elif current_shooting_angle == SHOOT_ANGLE.DOWNWARD_B:
#		var radian = deg2rad(abs(angle_map[current_shooting_angle]))
#		position += Vector2(movement_speed * cos(radian), -(movement_speed * sin(radian)))

func _physics_process(delta):
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	if !is_move_disabled:
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

	if !is_shoot_disabled:
		shoot_staff()
		
	if started_jumping and !is_jump_disabled:
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
	if fire_rate_timer.is_stopped():
		var other_way = true
		if other_way:
			if Input.is_action_pressed("up"):
				current_shooting_angle = SHOOT_ANGLE.UPWARD_B
				move_arrow(SHOOT_ANGLE.UPWARD_B)
				shoot(current_shooting_angle)
			elif Input.is_action_pressed("down"):
				current_shooting_angle = SHOOT_ANGLE.DOWNWARD_B
				move_arrow(SHOOT_ANGLE.DOWNWARD_B)
				shoot(current_shooting_angle)
			elif Input.is_action_pressed("right"):
				current_shooting_angle = SHOOT_ANGLE.FORWARD_B
				move_arrow(SHOOT_ANGLE.FORWARD_B)
				shoot(current_shooting_angle)
		else:
			if Input.is_action_just_pressed("aim_up"):
				current_shooting_angle = SHOOT_ANGLE.UPWARD_B
				move_arrow(SHOOT_ANGLE.UPWARD_B)
			elif Input.is_action_just_pressed("aim_down"):
				current_shooting_angle = SHOOT_ANGLE.DOWNWARD_B
				move_arrow(SHOOT_ANGLE.DOWNWARD_B)
			elif Input.is_action_just_pressed("aim_forward"):
				current_shooting_angle = SHOOT_ANGLE.FORWARD_B
				move_arrow(SHOOT_ANGLE.FORWARD_B)
				#shoot(current_shooting_angle)
	#	if Input.is_action_just_pressed("hold_test"):
	#		if current_shooting_angle == SHOOT_ANGLE.FORWARD_B:
	#			current_shooting_angle = SHOOT_ANGLE.UPWARD_B
	#			move_arrow(SHOOT_ANGLE.UPWARD_B)
	#		elif current_shooting_angle == SHOOT_ANGLE.UPWARD_B:
	#			current_shooting_angle = SHOOT_ANGLE.DOWNWARD_B
	#			move_arrow(SHOOT_ANGLE.DOWNWARD_B)
	#		elif current_shooting_angle == SHOOT_ANGLE.DOWNWARD_B:
	#			current_shooting_angle = SHOOT_ANGLE.FORWARD_B
	#			move_arrow(SHOOT_ANGLE.FORWARD_B)
		print(current_shooting_angle)
			
		if Input.is_action_pressed("shoot"):
			shoot(current_shooting_angle)
			
		if Input.is_action_just_pressed("hit"):
			hit()
		
func hit():
	for node in get_tree().get_root().get_children():
		if node.name == "Hit":
			return
	var _physical_attack = physical_attack.instance()
	get_tree().get_root().add_child(_physical_attack)
	_physical_attack.location_offset = Vector2(40,2)

func shoot(angle):
	var _gunshot = gunshot.instance()
	_gunshot.set_bullet_type(angle)
	get_tree().get_root().add_child(_gunshot)
	_gunshot.position = self.position + Vector2(80,2)
	fire_rate_timer.start()

func _on_disable_player_action(to_disable):
	# 0 == disable everything, including movement and jumping
	# 1 == disable everything except movement and jumping
	if int(to_disable) == 0:
		is_shoot_disabled = !is_shoot_disabled
		is_jump_disabled = !is_jump_disabled
		is_move_disabled = !is_move_disabled

func _on_collided_with_player(damage):
	if invul_timer.is_stopped():
		current_health = current_health - damage
		invul_timer.start()
		modulate.a = 0.5
		if current_health <= 0:
			self.queue_free()
			Events.emit_signal("game_over")
		else:
			Events.emit_signal("player_damaged", damage)
