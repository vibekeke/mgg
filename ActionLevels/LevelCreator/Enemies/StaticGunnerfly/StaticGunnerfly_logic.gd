extends Node

class_name StaticGunnerfly

const gunnerfly_bullet = preload("res://ActionLevels/LevelCreator/Enemies/StaticGunnerfly/StaticGunnerflyProjectile.tscn")
@export var rotate_speed: int = 80
@export var spawn_point_count: int = 3
@export var fire_rate_timer_wait_time: float = 0.2
@export var radius: int = 100
@export var projectile_speed: float = 100.0
var debug_mode = false


@onready var parent_node = self.get_parent()
@onready var initial_health_value: int = parent_node.health_value
@onready var fire_rate_timer = Timer.new()
@onready var rotator = parent_node.get_node("%Rotator")
@onready var current_phase: int = 0
@onready var debug_texture = preload("res://icon.png")
@onready var path2d = parent_node.get_node_or_null("Path2D")
@onready var path_follow = path2d.get_node_or_null("PathFollow2D")

const ON_SCREEN_TIME : float = 8.0 # seconds
@onready var on_screen_timer : Timer = Timer.new()
var allow_move_forward : bool = false

var default_path_speed = 300
var hit_end : bool = false

const phase_patterns = {
	0: {
		'rotate_speed': 0, # speed of rotation of bullet generator
		'spawn_point_count': 1, # number of bullets to spawn at one time, equivalent of angles to complete a circle, e.g. 3 = 120 degrees at each point
		'fire_rate_timer_wait_time': 1.0, # how often to fire in seconds
		'radius': 1, # size of radius of bullet spawning, influences initial "closeness" of bullets
		'projectile_speed': -850 # speed of the projectiles that are generated
	}
}

func setup_on_screen_timer():
	on_screen_timer.wait_time = ON_SCREEN_TIME
	on_screen_timer.autostart = true
	on_screen_timer.connect("timeout", Callable(self, "_on_screen_timer_timeout"))
	add_child(on_screen_timer)
	on_screen_timer.start()

func _on_screen_timer_timeout():
	allow_move_forward = true

func _ready():
	setup_on_screen_timer()
	$CanvasLayer.visible = debug_mode
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
	fire_rate_timer.set_name("fire_rate_timer")
	fire_rate_timer.connect("timeout", Callable(self, "_on_fire_rate_timeout"))
	self.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	for s in rotator.get_children():
		var bullet = gunnerfly_bullet.instantiate()
		bullet.add_to_group("static_gunnerfly_bullets")
		bullet.speed = projectile_speed
		AudioManager.playSFX("gunshot", 1.0, -1.0)
		get_tree().current_scene.add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
		await get_tree().create_timer(0.3).timeout
		AudioManager.playSFX("gun_reload", 1.0, -10.0)

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

func _physics_process(delta):
	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)
	if parent_node.global_position.x >= 1000:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta
	path_follow.set_offset(path_follow.get_offset() + default_path_speed * delta)
	if allow_move_forward:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_spawn_height():
	return DataClasses.SpawnHeight.MED_ONLY

func get_enemy_class():
	return "StaticGunnerfly"


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
