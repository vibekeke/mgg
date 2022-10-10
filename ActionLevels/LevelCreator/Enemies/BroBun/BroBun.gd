extends Node

class_name BroBun
onready var parent_node = self.get_parent()

const bro_bun_bullet = preload("res://ActionLevels/LevelCreator/Enemies/BroBun/BroBunProjectile.tscn")
export (int) var rotate_speed = 100
export (int) var spawn_point_count = 8
export (float) var fire_rate_timer_wait_time = 1.0
export (int) var radius = 135
export (float) var projectile_speed = 100.0

onready var spawned_bullets = 0
onready var fire_rate_timer = Timer.new()
onready var rotator = parent_node.get_node("Rotator")
onready var bullet_list = []
onready var rotate_lock_value
onready var debug_texture = load("res://icon.png")
var player_position
var has_fired = false

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("bro_bun_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	fire_rate_timer.one_shot = true
	parent_node.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		launch_bullet(bullet)
		has_fired = true
		
func launch_bullet(bullet: Object):
	if player_position != null:
		bullet.player_position = player_position
		bullet.shoot_towards = true
	else:
		print_debug("No player position found! Did you check the scene tree?")


func _ready():
	parent_node.has_invulnerability = true
	_fire_rate_timer_setup()
	_setup_bullets()
	Events.connect("player_global_position", self, "_on_player_global_position")

func _on_player_global_position(player_global_position):
	player_position = player_global_position

func get_spawn_height():
	return DataClasses.SpawnHeight.MED_ONLY

func _setup_bullets():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = bro_bun_bullet.instance()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		spawn_point.add_to_group("bullets")
		spawn_point.speed = projectile_speed
		rotator.add_child(spawn_point)
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	fire_rate_timer.start()

func _process(delta):
	if has_fired:
		parent_node.has_invulnerability = false

func _physics_process(delta):
	if parent_node.initial_scroll_speed > 0:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta
	if !has_fired:
		var new_rotation = rotator.rotation_degrees + rotate_speed * delta
		rotator.rotation_degrees = fmod(new_rotation, 360)


func get_class():
	return self.name
