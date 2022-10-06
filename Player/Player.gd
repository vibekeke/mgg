extends KinematicBody2D

onready var _animation_player = $AnimatedSprite/AnimationPlayer
onready var _animation_tree = $AnimatedSprite/AnimationTree
onready var _anim_state = _animation_tree.get("parameters/playback")

const UP_DIRECTION := Vector2.UP

## health
export var max_health := 3
var current_health = max_health
var invul_timer = Timer.new()

## shooting
export var fire_rate_secs := 0.15
var fire_rate_timer = Timer.new()
enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }
var angle_map = { SHOOT_ANGLE.FORWARD_B: 0 , SHOOT_ANGLE.UPWARD_B: -30, SHOOT_ANGLE.DOWNWARD_B: -330 }
var current_shooting_angle = SHOOT_ANGLE.FORWARD_B


## jumps and movement
export var horizontal_movement_speed := 600.0
export var max_jump_height : float = 500.0
export var min_jump_height : float = 200.0
export var jump_time_to_peak : float = 0.6
export var jump_time_to_descent : float = 0.45

onready var jump_velocity : float = ((2.0 * max_jump_height) / jump_time_to_peak) * -1.0
onready var double_jump_velocity : float = ((2.0 * max_jump_height + 5) / jump_time_to_peak) * -1.0
onready var min_jump_velocity : float = ((2.0 * min_jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * max_jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * max_jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
export (bool) var debug_mode = false

var slide_adjust_timer = Timer.new()
var is_sliding = false

var velocity := Vector2.ZERO
var previous_frame_velocity
var can_double_jump = false
var has_double_jumped = false

# pausing and cutscenes
var is_jump_disabled = false
var is_shoot_disabled = false
var is_move_disabled = false

export (PackedScene) var gunshot
export (PackedScene) var physical_attack
export (PackedScene) var charge_shot

onready var has_charge_shot = false

var sprite_anim_to_player_name = {
	'run': 'Run',
	'landed': 'Landing',
	'falling': 'FallingLoop',
	'during_jump': 'AboutToFall',
	'init_jump': 'RisingJump'
}

func _ready():
	Events.connect("collided_with_player", self, "_on_collided_with_player")
	Events.connect("disable_player_action", self, "_on_disable_player_action")
	Events.connect("transition_to_scene", self, "_player_transition_to_scene")
	Events.connect("collected_heart", self, "_on_collected_heart")
	Events.connect("has_charge_shot", self, "_on_has_charge_shot")
	_animation_tree.active = true
	_anim_state.travel("Run")
	_invul_timer_setup()
	_fire_rate_timer_setup()
	if debug_mode:	
		$DebugCanvasLayer/Control/VBoxContainer/FireRateTitle.text = "Fire Rate Seconds: " + str(fire_rate_secs)
		$DebugCanvasLayer/Control/VBoxContainer/FireRateSlider.value = fire_rate_secs

		$DebugCanvasLayer/Control/VBoxContainer/MovementSpeedTitle.text = "Movement Speed: " + str(horizontal_movement_speed)
		$DebugCanvasLayer/Control/VBoxContainer/MovementSpeedSlider.value = horizontal_movement_speed
		
		$DebugCanvasLayer/Control/VBoxContainer/MaxHeightJumpTitle.text = "Max Jump Height: " + str(max_jump_height)
		$DebugCanvasLayer/Control/VBoxContainer/MaxHeightJumpSlider.value = max_jump_height

		$DebugCanvasLayer/Control/VBoxContainer/MinHeightJumpTitle.text = "Min Jump Height: " + str(min_jump_height)
		$DebugCanvasLayer/Control/VBoxContainer/MinHeightJumpSlider.value = min_jump_height
		
		$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToPeakTitle.text = "Gravity Up: " + str(jump_time_to_peak)
		$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToPeakSlider.value = jump_time_to_peak
		
		$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToDescentTitle.text = "Gravity Down: " + str(jump_time_to_descent)
		$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToDescentSlider.value = jump_time_to_descent

		$DebugCanvasLayer/Control/VBoxContainer/AnimationStateTitle.text = "Animation: " + sprite_anim_to_player_name[$AnimatedSprite.animation]
	else:
		$DebugCanvasLayer.visible = false

func _player_transition_to_scene():
	print("Player has transitioned to scene")

func _on_has_charge_shot():
	has_charge_shot = true

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

func get_gravity() -> float:
	var gravity
	if velocity.y < 0.0:
		gravity = jump_gravity
		_anim_state.travel("RisingLoop")
	else:
		gravity = fall_gravity
		if !is_on_floor():
			_anim_state.travel("FallingLoop")
	# velocity is negative so character is rising
	# velocity is within 20% of total jump velocity, so character is approaching the peak
	# of their jump
	if velocity.y < 0 and velocity.y > jump_velocity * 0.5:
		print("play about to fall")
		_anim_state.travel("AboutToFall")
	return gravity

func jump_logic():
	if Input.is_action_just_pressed("jump") and !is_on_floor() and can_double_jump:
		can_double_jump = false
		has_double_jumped = true
		velocity.y = double_jump_velocity
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and !has_double_jumped:
		can_double_jump = false
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and !is_on_floor() && velocity.y < min_jump_velocity and !has_double_jumped:
		can_double_jump = false
		velocity.y = min_jump_velocity


func shoot(angle):
	var _gunshot = gunshot.instance()
	_gunshot.add_to_group("player_bullet")
	_gunshot.set_bullet_type(angle)
	get_tree().get_root().add_child(_gunshot)
	_gunshot.position = self.position + Vector2(80,2)
	$BulletFire.play(0.0)
	fire_rate_timer.start()

func shoot_hold_check():
	if !Input.is_action_pressed("right"):
		return
	yield(get_tree().create_timer(5), "timeout")
	if !Input.is_action_pressed("right"):
		return

func charge_shot_present():
	return get_tree().get_nodes_in_group("player_charge_shot").size() > 0

func fire_charge_shot():
	var _charge_shot = charge_shot.instance()
	_charge_shot.add_to_group("player_bullet")
	_charge_shot.add_to_group("player_charge_shot")
	get_tree().get_root().add_child(_charge_shot)
	_charge_shot.position = self.position + Vector2(1200,2)
	Events.emit_signal("fired_charge_shot")

func attack_logic():
	if fire_rate_timer.is_stopped():
		if has_charge_shot:
			if Input.is_action_pressed("charge_shot"):
				has_charge_shot = false
				fire_charge_shot()
		if !charge_shot_present():
			if Input.is_action_pressed("up"):
				current_shooting_angle = SHOOT_ANGLE.UPWARD_B
				shoot(current_shooting_angle)
			elif Input.is_action_pressed("down"):
				current_shooting_angle = SHOOT_ANGLE.DOWNWARD_B
				shoot(current_shooting_angle)
			elif Input.is_action_just_pressed("right"):
				shoot_hold_check()
			elif Input.is_action_pressed("right"):
				current_shooting_angle = SHOOT_ANGLE.FORWARD_B
				shoot(current_shooting_angle)
			if Input.is_action_just_pressed("hit"):
				physical_attack()

func debug_recalculate_jump_maths():
	jump_velocity = ((2.0 * max_jump_height) / jump_time_to_peak) * -1.0
	double_jump_velocity = ((2.0 * max_jump_height + 5) / jump_time_to_peak) * -1.0
	min_jump_velocity = ((2.0 * min_jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * max_jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	fall_gravity = ((-2.0 * max_jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func physical_attack():
	for node in get_tree().get_root().get_children():
		if node.name == "Hit":
			return
	var _physical_attack = physical_attack.instance()
	get_tree().get_root().add_child(_physical_attack)
	_physical_attack.location_offset = Vector2(40,2)

func _on_disable_player_action(to_disable):
	# 0 == disable everything, including movement and jumping
	# 1 == disable everything except movement and jumping
	if int(to_disable) == 0:
		is_shoot_disabled = !is_shoot_disabled
		is_jump_disabled = !is_jump_disabled
		is_move_disabled = !is_move_disabled

func _on_collided_with_player(damage):
	if debug_mode:
		return
	if invul_timer.is_stopped():
		current_health = current_health - damage
		invul_timer.start()
		modulate.a = 0.5
		if current_health <= 0:
			Events.emit_signal("player_damaged", damage)
			Events.emit_signal("game_over")
			self.queue_free()
		else:
			Events.emit_signal("player_damaged", damage)

func _on_collected_heart():
	current_health = clamp(current_health + 1, 0, max_health)

func _physics_process(delta):
	if is_on_floor():
		can_double_jump = false
		has_double_jumped = false
		_anim_state.travel("Run")
	
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	var _vertical_direction = (
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	)

	previous_frame_velocity = velocity
	if !is_move_disabled:
		velocity.y += get_gravity() * delta
		velocity.x = _horizontal_direction * horizontal_movement_speed


	if !is_shoot_disabled:
		attack_logic()
	
	if !is_jump_disabled:
		jump_logic()
	
	velocity = move_and_slide(velocity, UP_DIRECTION)

func _process(delta):
	Events.emit_signal("player_max_health", max_health)
	Events.emit_signal("player_global_position", self.global_position)
	Events.emit_signal("player_local_position", self.position)
	if debug_mode:
		$DebugCanvasLayer/Control/VBoxContainer/AnimationStateTitle.text = "Animation: " + sprite_anim_to_player_name[$AnimatedSprite.animation]


func _on_MovementSpeedSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/MovementSpeedSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/MovementSpeedTitle.text = "Movement Speed: " + str(value)
	horizontal_movement_speed = value


func _on_MaxHeightJumpSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/MaxHeightJumpSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/MaxHeightJumpTitle.text = "Max Height Jump: " + str(value)
	max_jump_height = value
	debug_recalculate_jump_maths()

func _on_MinHeightJumpSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/MinHeightJumpSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/MinHeightJumpTitle.text = "Min Height Jump: " + str(value)
	min_jump_height = value
	debug_recalculate_jump_maths()
	
func _on_JumpTimeToPeakSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToPeakSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToPeakTitle.text = "Gravity Up: " + str(value)
	jump_time_to_peak = value
	debug_recalculate_jump_maths()

func _on_JumpTimeToDescentSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToDescentSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/JumpTimeToDescentTitle.text = "Gravity Down: " + str(value)
	jump_time_to_descent = value
	debug_recalculate_jump_maths()

func _on_FireRateSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/FireRateSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/FireRateTitle.text = "Fire Rate Seconds: " + str(value)
	fire_rate_secs = value
	fire_rate_timer.set_wait_time(fire_rate_secs)
