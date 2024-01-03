extends KinematicBody2D

onready var hurt_area = $HurtArea
onready var slide_hurt_area = $SlideHurtArea
onready var standing_collision = $StandingCollisionShape
onready var sliding_collision = $SlidingCollisionShape
onready var visibility_notifier = $VisibilityNotifier2D


onready var staff_forward = $StaffForward
onready var _forward_animation_player = $StaffForward/AnimationPlayer
onready var _forward_animation_tree = $StaffForward/AnimationTree
onready var _forward_anim_state = _forward_animation_tree.get("parameters/playback")

onready var staff_up = $StaffUp
onready var _up_animation_player = $StaffUp/AnimationPlayer
onready var _up_animation_tree = $StaffUp/AnimationTree
onready var _up_anim_state = _up_animation_tree.get("parameters/playback")

onready var staff_down = $StaffDown
onready var _down_animation_player = $StaffDown/AnimationPlayer
onready var _down_animation_tree = $StaffDown/AnimationTree
onready var _down_anim_state = _down_animation_tree.get("parameters/playback")

onready var _floor = get_node_or_null("%Floor")

const UP_DIRECTION := Vector2.UP
const DOWN_DIRECTION := Vector2.DOWN

## health
export var max_health := 3
var current_health : int = max_health
var invul_timer : Timer = Timer.new()

## Respawning
var respawn_timer : Timer = Timer.new()
var start_respawning_player : bool = false

## shooting
export var fire_rate_secs := 0.15
var fire_rate_timer : Timer = Timer.new()
enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }
var angle_map = { SHOOT_ANGLE.FORWARD_B: 0 , SHOOT_ANGLE.UPWARD_B: -30, SHOOT_ANGLE.DOWNWARD_B: -330 }
var current_shooting_angle = SHOOT_ANGLE.FORWARD_B


## jumps and movement
export var horizontal_movement_speed := 600.0
export var max_jump_height : float = 500.0
export var min_jump_height : float = 200.0
export var jump_time_to_peak : float = 0.6
export var jump_time_to_descent : float = 0.4
export var float_time_to_descent : float = 4.0
export var fast_fall_time_to_descent : float = 0.3

onready var jump_velocity : float = ((2.0 * max_jump_height) / jump_time_to_peak) * -1.0
onready var double_jump_velocity : float = ((2.0 * max_jump_height + 5) / jump_time_to_peak) * -1.0
onready var min_jump_velocity : float = ((2.0 * min_jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * max_jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * max_jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
onready var float_gravity : float = ((-2.0 * max_jump_height) / (float_time_to_descent * float_time_to_descent)) * -1.0
onready var fast_fall_gravity : float = ((-2.0 * max_jump_height) / (fast_fall_time_to_descent * fast_fall_time_to_descent)) * -1.0
var float_halt : bool = false
var has_floated : bool = false

export (bool) var debug_mode = false

# sliding
var slide_duration_timer = Timer.new()
var slide_again_timer = Timer.new()
var is_sliding = false

export var flash_charge_timer = 0.2
var flash_charge_shoot_timer = Timer.new()
var original_color : Color = Color(1.0, 1.0, 1.0, 1.0)
var flash_color : Color = Color(0.5, 1.0, 0.98, 1.0)

# speed of the slide
export var slide_value = 1200.0
# how long the slide lasts for, in seconds
export var slide_duration = 0.4
# how long to wait until you can slide again, in seconds
var slide_again_duration = 0.3


var velocity := Vector2.ZERO
var can_double_jump = false
var has_double_jumped = false

# pausing and cutscenes
var is_jump_disabled = false
var is_shoot_disabled = false
var is_move_disabled = false
var in_battle_dialogue = false

export (PackedScene) var gunshot
export (PackedScene) var charge_shot

onready var has_charge_shot = false

var sprite_anim_to_player_name = {
	'run': 'Run',
	'landed': 'Landing',
	'falling': 'FallingLoop',
	'during_jump': 'AboutToFall',
	'init_jump': 'RisingJump',
	'slide': 'Slide'
}

func _ready():
	Events.connect("collided_with_player", self, "_on_collided_with_player")
	Events.connect("disable_player_action", self, "_on_disable_player_action")
	Events.connect("transition_to_scene", self, "_player_transition_to_scene")
	Events.connect("collected_heart", self, "_on_collected_heart")
	Events.connect("has_charge_shot", self, "_on_has_charge_shot")
	Events.connect("in_battle_dialogue", self, "_on_in_battle_dialogue")
	
	visibility_notifier.connect("screen_exited", self, "_on_screen_exited")
	_forward_animation_tree.active = true
	_up_animation_tree.active = true
	_down_animation_tree.active = true
	_invul_timer_setup()
	_fire_rate_timer_setup()
	_slide_again_timer_setup()
	_slide_duration_timer_setup()
	_flash_charge_shoot_setup()
	_respawn_timer_setup()
	staff_forward.frame = 0
	staff_up.frame = 0
	staff_down.frame = 0
	travel_to_animation("Run")
	setup_debug_canvas(debug_mode)

func _on_in_battle_dialogue(_in_battle_dialogue):
	in_battle_dialogue = _in_battle_dialogue
	

func _on_screen_exited():
	if self.global_position.y > 0 and !in_battle_dialogue:
		take_damage(1)
		if current_health > 0:
			start_respawning_player = true

func _player_transition_to_scene(scene_name):
	print("Player will transition to scene", scene_name)

func _on_has_charge_shot():
	has_charge_shot = true

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	fire_rate_timer.set_wait_time(fire_rate_secs)
	self.add_child(fire_rate_timer)


func _slide_duration_timer_setup():
	slide_duration_timer.set_name("slide_duration_timer")
	slide_duration_timer.connect("timeout", self, "_on_slide_duration_timeout")
	slide_duration_timer.set_wait_time(slide_duration)
	self.add_child(slide_duration_timer)

func _slide_again_timer_setup():
	slide_again_timer.set_name("slide_again_timer")
	slide_again_timer.connect("timeout", self, "_on_slide_again_timeout")
	slide_again_timer.set_wait_time(slide_again_duration)
	self.add_child(slide_again_timer)

func _invul_timer_setup():
	invul_timer.set_name("invul_timer")
	invul_timer.connect("timeout", self, "_on_invul_timeout")
	invul_timer.set_wait_time(1.0)
	self.add_child(invul_timer)

func _flash_charge_shoot_setup():
	flash_charge_shoot_timer.set_name("flash_charge_shoot_timer")
	flash_charge_shoot_timer.connect("timeout", self, "_on_flash_charge_shoot_timeout")
	flash_charge_shoot_timer.set_wait_time(flash_charge_timer)
	flash_charge_shoot_timer.set_one_shot(false)
	self.add_child(flash_charge_shoot_timer)

func _respawn_timer_setup():
	respawn_timer.set_name("respawn_timer")
	#respawn_timer.connect("timeout", self, "_on_respawn_timeout")
	respawn_timer.set_wait_time(1.0)
	respawn_timer.set_one_shot(true)
	self.add_child(respawn_timer)

func _on_slide_duration_timeout():
	slide_duration_timer.stop()
	slide_again_timer.start()
	is_sliding = false

func _on_fire_rate_timeout():
	fire_rate_timer.stop()

func _on_slide_again_timeout():
	slide_again_timer.stop()

func _on_invul_timeout():
	modulate.a = 1
	invul_timer.stop()

func _on_flash_charge_shoot_timeout():
	if self.modulate == original_color:
		self.modulate = flash_color

func travel_to_animation(animation: String):
	_forward_anim_state.travel(animation)
	_up_anim_state.travel(animation)
	_down_anim_state.travel(animation)

func handle_collision_shapes():
	if is_sliding:
		sliding_collision.disabled = false
		slide_hurt_area.get_node("CollisionShape2D").disabled = false
		standing_collision.disabled = true
		hurt_area.get_node("CollisionShape2D").disabled = true
	else:
		sliding_collision.disabled = true
		slide_hurt_area.get_node("CollisionShape2D").disabled = true
		standing_collision.disabled = false
		hurt_area.get_node("CollisionShape2D").disabled = false

func get_float_gravity_value() -> float:
	return float_gravity

func get_gravity() -> float:
	var gravity
	if velocity.y < 0.0:
		gravity = jump_gravity
		travel_to_animation("RisingLoop")
	else:
		if Input.is_action_pressed("float") and !is_on_floor() and !has_floated:
			gravity = float_gravity
		elif Input.is_action_pressed("move_down"):
			gravity = fast_fall_gravity
		else:
			gravity = fall_gravity
		if !is_on_floor():
			travel_to_animation("FallingLoop")
	# velocity is negative so character is rising
	# velocity is within some percentage of total jump velocity, so character is approaching the peak
	# of their jump
	if velocity.y < 0 and velocity.y > jump_velocity * 0.5:
		travel_to_animation("AboutToFall")
	if start_respawning_player:
		gravity = gravity * -1.0
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
	if angle == SHOOT_ANGLE.FORWARD_B:
		_gunshot.position = self.position + Vector2(180,35)
	if angle == SHOOT_ANGLE.UPWARD_B:
		_gunshot.position = self.position + Vector2(180,-90)
	if angle == SHOOT_ANGLE.DOWNWARD_B:
		_gunshot.position = self.position + Vector2(200,160)
	$BulletFire.play(0.0)
	fire_rate_timer.start()

func charge_shot_present():
	return get_tree().get_nodes_in_group("player_charge_shot").size() > 0

func fire_charge_shot():
	var _charge_shot = charge_shot.instance()
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
			elif Input.is_action_pressed("right"):
				current_shooting_angle = SHOOT_ANGLE.FORWARD_B
				shoot(current_shooting_angle)

func debug_recalculate_jump_maths():
	jump_velocity = ((2.0 * max_jump_height) / jump_time_to_peak) * -1.0
	double_jump_velocity = ((2.0 * max_jump_height + 5) / jump_time_to_peak) * -1.0
	min_jump_velocity = ((2.0 * min_jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * max_jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	fall_gravity = ((-2.0 * max_jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _on_disable_player_action(to_disable):
	# 0 == disable everything, including movement and jumping
	# 1 == disable everything except movement and jumping
	if int(to_disable) == 0:
		is_shoot_disabled = !is_shoot_disabled
		is_jump_disabled = !is_jump_disabled
		is_move_disabled = !is_move_disabled

func take_damage(damage):
	if !in_battle_dialogue:
		current_health = current_health - damage
		Events.emit_signal("player_damaged", damage)
		Events.emit_signal("player_current_health", current_health)
		if current_health > 0:
			invul_timer.start()
			modulate.a = 0.5
		if current_health <= 0:
			Events.emit_signal("game_over")
			self.queue_free()

func _on_collided_with_player(damage):
	if debug_mode:
		return
	if invul_timer.is_stopped() && !charge_shot_present():
		take_damage(damage)

func _on_collected_heart():
	current_health = clamp(current_health + 1, 0, max_health)
	Events.emit_signal("player_current_health", current_health)

func _physics_process(delta):
	if self.global_position.y < 540 && start_respawning_player:
		start_respawning_player = false
	if is_on_floor() and is_sliding:
		travel_to_animation("Slide")
	elif is_on_floor():
		can_double_jump = false
		has_double_jumped = false
		has_floated = false
		travel_to_animation("Run")
	
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	var _vertical_direction = (
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	)
	
	if charge_shot_present():
		if flash_charge_shoot_timer.is_stopped():
			flash_charge_shoot_timer.start()
	
	if !charge_shot_present():
		if !flash_charge_shoot_timer.is_stopped():
			flash_charge_shoot_timer.stop()
			self.modulate = original_color

	if !is_move_disabled:
		velocity.y += get_gravity() * delta
		velocity.x = _horizontal_direction * horizontal_movement_speed
		if is_sliding:
			velocity.x = 1 * slide_value
		if Input.is_action_just_pressed("move_down") and is_on_floor() and slide_duration_timer.is_stopped() and !charge_shot_present():
			if slide_again_timer.is_stopped():
				initiate_slide()

	handle_collision_shapes()
#	actions_based_on_animation()
	if !is_sliding and !is_shoot_disabled:
		attack_logic()
	
	if !is_sliding and !is_jump_disabled:
		jump_logic()
	
	# the 5 lines below are a crime against humanity and i dont actually get why this works
	# TODO: write this in a way that makes sense lol
	if !has_floated:
		if Input.is_action_pressed("float") and velocity.y > 0 and !float_halt:
			float_halt = true
			velocity.y = 0 # halt velocity if you are floating
		elif Input.is_action_just_released("float"):
			float_halt = false
			has_floated = true
	if start_respawning_player:
		if _floor != null:
			_floor.turn_off_collision()
		velocity = move_and_slide(velocity, DOWN_DIRECTION)
	else:
		if _floor != null:
			_floor.turn_on_collision()
		velocity = move_and_slide(velocity, UP_DIRECTION)

func initiate_slide():
	# player has committed to slide for X number of frames
	# disable jumping and directional movement
	# move player forward for X number of frames
	# allow slide to be actionable before it's fully complete
	# e.g. you can jump some number of frames before the slide is over
	travel_to_animation("Slide")
	slide_duration_timer.start()
	is_sliding = true

func animation_to_show():
	if Input.is_action_pressed("up") and !is_shoot_disabled:
		$StaffForward.visible = false
		$StaffUp.visible = true
		$StaffDown.visible = false
	elif Input.is_action_pressed("down") and !is_shoot_disabled:
		$StaffForward.visible = false
		$StaffUp.visible = false
		$StaffDown.visible = true
	else:
		if !is_shoot_disabled:
			$StaffForward.visible = true
			$StaffUp.visible = false
			$StaffDown.visible = false

func get_active_aiming_state():
	if $StaffForward.visible:
		return _forward_anim_state
	if $StaffUp.visible:
		return _up_anim_state
	if $StaffDown.visible:
		return _down_anim_state

func current_animation():
	return get_active_aiming_state().get_current_node()

func _process(delta):
	Events.emit_signal("player_max_health", max_health)
	Events.emit_signal("player_global_position", self.global_position)
	Events.emit_signal("player_local_position", self.position)
	animation_to_show()
	if debug_mode:
		$DebugCanvasLayer/Control/VBoxContainer/AnimationStateTitle.text = "Animation: " + sprite_anim_to_player_name[$StaffForward.animation]


func setup_debug_canvas(debug_enabled: bool):
	if debug_enabled:
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
		

		$DebugCanvasLayer/Control/VBoxContainer/AnimationStateTitle.text = "Animation: " + sprite_anim_to_player_name[$StaffForward.animation]
		
		$DebugCanvasLayer/Control/VBoxContainer/SlideDurationTitle.text = "Slide Duration: " + str(slide_duration)
		$DebugCanvasLayer/Control/VBoxContainer/SlideDurationSlider.value = slide_duration
		
		$DebugCanvasLayer/Control/VBoxContainer/SlideSpeedTitle.text = "Slide Speed: " + str(slide_value)
		$DebugCanvasLayer/Control/VBoxContainer/SlideSpeedSlider.value = slide_value
		
	else:
		$DebugCanvasLayer.visible = false


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


func _on_SlideSpeedSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/SlideSpeedSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/SlideSpeedTitle.text = "Slide Speed: " + str(value)
	slide_value = value


func _on_SlideDurationSlider_value_changed(value):
	$DebugCanvasLayer/Control/VBoxContainer/SlideDurationSlider.value = value
	$DebugCanvasLayer/Control/VBoxContainer/SlideDurationTitle.text = "Slide Duration: " + str(value)
	slide_duration = value
	slide_duration_timer.set_wait_time(slide_duration)
