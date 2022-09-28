extends Node

class_name BigBird

const lil_bird_bullet = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBirdProjectile.tscn")
export (int) var rotate_speed = 80
export (int) var spawn_point_count = 3
export (float) var fire_rate_timer_wait_time = 0.2
export (int) var radius = 100
export (float) var projectile_speed = 100

onready var parent_node = self.get_parent()
onready var initial_health_value: int = parent_node.health_value
onready var fire_rate_timer = Timer.new()
onready var rotator = parent_node.get_node("Rotator")
onready var current_phase: int = 0

const phase_patterns = {
	0: {
		'rotate_speed': 100, # speed of rotation of bullet generator
		'spawn_point_count': 3, # number of bullets to spawn at one time, equivalent of angles to complete a circle, e.g. 3 = 120 degrees at each point
		'fire_rate_timer_wait_time': 0.5, # how often to fire in seconds
		'radius': 100, # size of radius of bullet spawning, influences initial "closeness" of bullets
		'projectile_speed': 100 # speed of the projectiles that are generated
	},
	1: {
		'rotate_speed': 90,
		'spawn_point_count': 4,
		'fire_rate_timer_wait_time': 0.4,
		'radius': 100,
		'projectile_speed': 150
	},
	2: {
		'rotate_speed': 80,
		'spawn_point_count': 5,
		'fire_rate_timer_wait_time': 0.5,
		'radius': 100,
		'projectile_speed': 100
	},
	# phase 3 is a joke for testing weird shit
	3: {
		'rotate_speed': 80,
		'spawn_point_count': 9,
		'fire_rate_timer_wait_time': 0.001,
		'radius': 100,
		'projectile_speed': 500
	}
}

func _ready():
	apply_new_bullet_phase(current_phase)
	_fire_rate_timer_setup()
	_setup_bullets()

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("boss_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	parent_node.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	for s in rotator.get_children():
		var bullet = lil_bird_bullet.instance()
		bullet.speed = projectile_speed
		get_tree().get_root().add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation

func _setup_bullets():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)
	
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	fire_rate_timer.start()


func apply_new_bullet_phase(phase_number: int):
	print("transitioning to phase -> ", phase_number)
	rotate_speed = phase_patterns[phase_number]['rotate_speed']
	spawn_point_count = phase_patterns[phase_number]['spawn_point_count']
	fire_rate_timer_wait_time = phase_patterns[phase_number]['fire_rate_timer_wait_time']
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	radius = phase_patterns[phase_number]['radius']
	projectile_speed = phase_patterns[phase_number]['projectile_speed']

func _process(delta):
	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)
	if parent_node.health_value < (initial_health_value * 0.6) and current_phase != 1 and current_phase != 2:
		current_phase = 1
		apply_new_bullet_phase(current_phase)
	elif parent_node.health_value < (initial_health_value * 0.3) and current_phase != 2:
		current_phase = 2
		apply_new_bullet_phase(current_phase)

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BigBird"
