extends Node

class_name BigBird

const lil_bird_bullet = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBirdProjectile.tscn")
export (int) var rotate_speed = 80
export (int) var spawn_point_count = 3
export (float) var fire_rate_timer_wait_time = 0.2
export (int) var radius = 100

onready var parent_node = self.get_parent()
onready var fire_rate_timer = Timer.new()
onready var rotator = parent_node.get_node("Rotator")
onready var bullet_paths = get_tree().get_nodes_in_group("bullet_paths")

func _ready():
	_fire_rate_timer_setup()
	_setup_bullets()

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("boss_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	parent_node.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	for s in rotator.get_children():
		var bullet = lil_bird_bullet.instance()
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

func _process(delta):
	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BigBird"
