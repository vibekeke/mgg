extends Node

class_name BigBird

const lil_bird_bullet = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBirdProjectile.tscn")
@export var rotate_speed: int = 80
@export var spawn_point_count: int = 3
@export var fire_rate_timer_wait_time: float = 0.2
@export var radius: int = 100
@export var projectile_speed: float = 100.0
var debug_mode = false
@onready var intro_complete = false

@onready var initial_color_value = 0.0
@onready var initial_alpha_value = 0.0
@onready var intro_audio_played = false

@onready var parent_node = self.get_parent()
@onready var initial_health_value: int = parent_node.health_value
@onready var fire_rate_timer = Timer.new()
@onready var rotator = parent_node.get_node("Rotator")
@onready var current_phase: int = 0
@onready var debug_texture = preload("res://icon.png")

@onready var audio_phase_1_played : bool = false
@onready var audio_phase_2_played : bool = false

@export var pacifist_mode : bool = false
@onready var hurt_during_pacifist : bool = false
const PACIFIST_TIMEOUT : float = 30.0
@onready var pacifist_timer : Timer = Timer.new()
@onready var pacifist_complete : bool = false

@export var level1_event_betrayal_dialog : Resource

const phase_patterns = {
	0: {
		'rotate_speed': 80, # speed of rotation of bullet generator
		'spawn_point_count': 2, # number of bullets to spawn at one time, equivalent of angles to complete a circle, e.g. 3 = 120 degrees at each point
		'fire_rate_timer_wait_time': 0.6, # how often to fire in seconds
		'radius': 100, # size of radius of bullet spawning, influences initial "closeness" of bullets
		'projectile_speed': 100 # speed of the projectiles that are generated
	},
	1: {
		'rotate_speed': 33,
		'spawn_point_count': 3,
		'fire_rate_timer_wait_time': 0.45,
		'radius': 110,
		'projectile_speed': 810
	},
	2: {
		'rotate_speed': 80,
		'spawn_point_count': 5,
		'fire_rate_timer_wait_time': 1.02,
		'radius': 40,
		'projectile_speed': 200
	},
	3: {
		'rotate_speed': 24,
		'spawn_point_count': 6,
		'fire_rate_timer_wait_time': 0.88,
		'radius': 110,
		'projectile_speed': 260
	}
}

func play_intro(delta):
	if !intro_audio_played:
		AudioManager.playSFX("BirdAppear", 1.2, -10)
		intro_audio_played = true
	if initial_alpha_value < 1.0:
		initial_alpha_value = initial_alpha_value + delta * 0.5
		initial_alpha_value = clamp(initial_alpha_value, 0.0, 1.0)
		parent_node.modulate = Color(0, 0, 0, initial_alpha_value)
		parent_node.has_invulnerability = true
	elif initial_color_value < 1.0:
		initial_color_value = initial_color_value + delta * 0.5
		initial_color_value = clamp(initial_color_value, 0.0, 1.0)
		parent_node.modulate = Color(initial_color_value, initial_color_value, initial_color_value, initial_alpha_value)
		parent_node.has_invulnerability = true
	else:
		intro_complete = true
		post_intro()

func _on_shot_during_pacifist():
	if pacifist_mode and !hurt_during_pacifist:
		pacifist_betrayal_reaction()

func display_betrayal_dialogue():
	MggDialogue.create_dialogue_balloon(
		"level1_event_boss_betrayal", 
		level1_event_betrayal_dialog, 
		# i'm sorry this exists god
		777, 
		DataClasses.Placement.LOWER, 
		DataClasses.CharacterPortrait.None,
		Color(0.0, 0.0, 0.0, 0.6),
		Color(0.3, 0.1, 0.5, 0.6),
		true,
		3.0
	)


func pacifist_betrayal_reaction():
	pacifist_mode = false
	hurt_during_pacifist = true
	pacifist_timer.stop()
	display_betrayal_dialogue()
	current_phase = 0
	transition_to_phase(0)

func initialise_pacifist_timer():
	pacifist_timer.connect("timeout", Callable(self, "_on_pacifist_timeout"))
	pacifist_timer.wait_time = PACIFIST_TIMEOUT
	pacifist_timer.autostart = false
	pacifist_timer.one_shot = false
	add_child(pacifist_timer)
	pacifist_timer.start()

func _on_pacifist_timeout():
	if current_phase < 2:
		transition_to_phase(current_phase + 1)
	elif current_phase == 2:
		current_phase = 3
		if !hurt_during_pacifist:
			Events.emit_signal("pacifist_successful")
		pacifist_complete = true
	else:
		pacifist_timer.stop()

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", Callable(self, "_on_dialogue_box_finished"))
	parent_node.connect("enemy_shot_by_player", Callable(self, "_on_shot_during_pacifist"))
	$CanvasLayer.visible = debug_mode
	pacifist_mode = StatsTracker.current_level_stats.killed_enemies == 0
	if pacifist_mode:
		initialise_pacifist_timer()
	parent_node.modulate = Color(0, 0, 0, 0)

func _on_dialogue_box_finished(node_id):
	if node_id == 666:
		parent_node.scale.x = -1

		# Old tween code commented out for Godot 4 compatibility:
		# var tween = Tween.new()
		# add_child(tween)
		# var target_x = parent_node.position.x + 3000
		# tween.interpolate_property(parent_node, "position:x", parent_node.position.x, target_x, 2.0, Tween.TRANS_QUART, Tween.EASE_IN)
		# tween.connect("tween_completed", self, "_on_escape_tween_completed", [tween])
		# tween.start()

		# New Godot 4 tween:
		var target_x = parent_node.position.x + 3000
		var escape_tween = get_tree().create_tween()
		escape_tween.tween_property(parent_node, "position:x", target_x, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		escape_tween.connect("finished", Callable(self, "_on_escape_tween_completed").bind(escape_tween))

func _on_escape_tween_completed(tween):
	# Old tween signature: func _on_escape_tween_completed(object, key, tween)
	# tween.queue_free()  # SceneTreeTween auto-frees
	parent_node.queue_free()

func post_intro():
	_fire_rate_timer_setup()
	apply_new_bullet_phase(current_phase)
	_setup_bullets()
	parent_node.has_invulnerability = false
	if debug_mode:
		$CanvasLayer/DebugSliders/VBoxContainer/RotationSpeedSlider.value = rotate_speed
		$CanvasLayer/DebugSliders/VBoxContainer/RotationSpeedTitle.text = "Rotation Speed: " + str(rotate_speed)

		$CanvasLayer/DebugSliders/VBoxContainer/SpawnCountSlider.value = spawn_point_count
		$CanvasLayer/DebugSliders/VBoxContainer/SpawnCountTitle.text = "Spawn Count: " + str(spawn_point_count)
		
		$CanvasLayer/DebugSliders/VBoxContainer/FireRateSlider.value = fire_rate_timer_wait_time
		$CanvasLayer/DebugSliders/VBoxContainer/FireRateTitle.text = "Fire Rate Seconds: " + str(fire_rate_timer_wait_time)

		$CanvasLayer/DebugSliders/VBoxContainer/RadiusSlider.value = radius
		$CanvasLayer/DebugSliders/VBoxContainer/RadiusTitle.text = "Radius: " + str(radius)
		
		$CanvasLayer/DebugSliders/VBoxContainer/ProjectileSpeedSlider.value = projectile_speed
		$CanvasLayer/DebugSliders/VBoxContainer/ProjectileSpeedTitle.text = "Projectile Speed: " + str(projectile_speed)

func set_pattern_debug():
	_setup_bullets()

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("boss_fire_rate_timer")
	fire_rate_timer.connect("timeout", Callable(self, "_on_fire_rate_timeout"))
	self.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	for s in rotator.get_children():
		var bullet = lil_bird_bullet.instantiate()
		bullet.speed = projectile_speed
		get_tree().current_scene.add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation

func _setup_bullets():
	var step = 2 * PI / spawn_point_count
	for _i in range(spawn_point_count):
		for n in rotator.get_children():
			rotator.remove_child(n)
			n.queue_free()
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		if debug_mode:
			spawn_point = Sprite2D.new()
			spawn_point.texture = debug_texture
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)

	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	fire_rate_timer.start()


func apply_new_bullet_phase(phase_number: int):
	if debug_mode:
		pass
	else:
		rotate_speed = phase_patterns[phase_number]['rotate_speed']
		spawn_point_count = phase_patterns[phase_number]['spawn_point_count']
		fire_rate_timer_wait_time = phase_patterns[phase_number]['fire_rate_timer_wait_time']
		fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
		radius = phase_patterns[phase_number]['radius']
		projectile_speed = phase_patterns[phase_number]['projectile_speed']
		_setup_bullets()

func trigger_audio_phases(current_phase: int):
	if current_phase == 1 and !audio_phase_1_played:
		audio_phase_1_played = true
		AudioManager.playSFX("BirdChirp1", 0.5, -8)
	if current_phase == 2 and !audio_phase_2_played:
		audio_phase_2_played = true
		AudioManager.playSFX("BirdChirp2", 0.5, -8)

func check_phase_transitions():
	if pacifist_mode:
		return # Timer-based phases handled separately

	var health_percentage = float(parent_node.health_value) / float(initial_health_value)
	var target_phase = get_phase_from_health(health_percentage)

	if target_phase != current_phase and target_phase > current_phase:
		transition_to_phase(target_phase)

func get_phase_from_health(health_percentage: float) -> int:
	if health_percentage > 0.6:
		return 0
	elif health_percentage > 0.3:
		return 1
	else:
		return 2

func transition_to_phase(new_phase: int):
	current_phase = new_phase
	trigger_audio_phases(current_phase)
	apply_new_bullet_phase(current_phase)

func _process(delta):
	if !intro_complete:
		play_intro(delta)
	else:
		check_phase_transitions()

func _physics_process(delta):
	if pacifist_complete and !fire_rate_timer.is_stopped():
		fire_rate_timer.stop()
	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_enemy_class():
	return "BigBird"


func _on_RotationSpeedSlider_value_changed(value):
	$CanvasLayer/DebugSliders/VBoxContainer/RotationSpeedTitle.text = "Rotation Speed: " + str(value)
	rotate_speed = int($CanvasLayer/DebugSliders/VBoxContainer/RotationSpeedSlider.value)
	set_pattern_debug()


func _on_SpawnCountSlider_value_changed(value):
	$CanvasLayer/DebugSliders/VBoxContainer/SpawnCountTitle.text = "Spawn Count: " + str(value)
	spawn_point_count = int($CanvasLayer/DebugSliders/VBoxContainer/SpawnCountSlider.value)
	set_pattern_debug()


func _on_FireRateSlider_value_changed(value):
	$CanvasLayer/DebugSliders/VBoxContainer/FireRateTitle.text = "Fire Rate Seconds: " + str(value)
	fire_rate_timer_wait_time = float($CanvasLayer/DebugSliders/VBoxContainer/FireRateSlider.value)
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	set_pattern_debug()


func _on_RadiusSlider_value_changed(value):
	$CanvasLayer/DebugSliders/VBoxContainer/RadiusTitle.text = "Radius: " + str(value)
	radius = int($CanvasLayer/DebugSliders/VBoxContainer/RadiusSlider.value)
	set_pattern_debug()


func _on_ProjectileSpeedSlider_value_changed(value):
	$CanvasLayer/DebugSliders/VBoxContainer/ProjectileSpeedTitle.text = "Projectile Speed: " + str(value)
	projectile_speed = int($CanvasLayer/DebugSliders/VBoxContainer/ProjectileSpeedSlider.value)
	set_pattern_debug()
