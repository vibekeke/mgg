extends Node

class_name StaticBroBear
# good luck understanding how this shit works in a week lol
# yo I was right I don't understand a thing!
onready var parent_node = self.get_parent()

const bro_bear_bullet = preload("res://ActionLevels/LevelCreator/Enemies/StaticBroBear/StaticBroBearProjectile.tscn")

export (int) var rotate_speed = 100
export (int) var spawn_point_count = 8
export (float) var fire_rate_timer_wait_time = 1.0
export (int) var radius = 135
export (float) var projectile_speed = 600.0

onready var fire_rate_timer = Timer.new()
onready var fire_again_timer = Timer.new()
onready var rotator = parent_node.get_node("%Rotator")
onready var path2d = parent_node.get_node_or_null("Path2D")
onready var path_follow = path2d.get_node_or_null("PathFollow2D")
var player_position
var has_fired = false
var default_path_speed = 300

const ON_SCREEN_TIME : float = 5.0 # seconds
onready var on_screen_timer : Timer = Timer.new()
var allow_move_forward : bool = false

func setup_on_screen_timer():
	on_screen_timer.wait_time = ON_SCREEN_TIME
	on_screen_timer.one_shot = false
	on_screen_timer.connect("timeout", self, "_on_screen_timer_timeout")
	add_child(on_screen_timer)
	on_screen_timer.start()

func _on_screen_timer_timeout():
	print("ye")
	allow_move_forward = true

func _fire_again_timer_setup():
	fire_again_timer.set_name("static_bro_bear_fire_again_timer")
	fire_again_timer.connect("timeout", self, "_on_fire_again_timeout")
	fire_again_timer.one_shot = false
	parent_node.add_child(fire_again_timer)

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("bro_bear_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	fire_rate_timer.one_shot = true
	parent_node.add_child(fire_rate_timer)

func _on_fire_again_timeout():
	if has_fired:
		return
	rotator.rotator_has_fired = false
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	fire_rate_timer.start()
	
func _on_fire_rate_timeout():
	if has_fired:
		return
	for bullet in get_tree().get_nodes_in_group("static_bro_bear_bullets"):
		var new_bullet = bro_bear_bullet.instance()
		new_bullet.position = bullet.global_position
		new_bullet.player_position = player_position
		new_bullet.shoot_towards = true
		new_bullet.speed = bullet.speed
		get_tree().current_scene.call_deferred("add_child", new_bullet)
	has_fired = true

func launch_bullet(bullet: Object):
	if player_position != null:
	
		rotator.rotator_has_fired = true
		bullet.player_position = player_position
		bullet.shoot_towards = true
		AudioManager.playSFX("LaserBlipShort", 1.0, -10.0)
		fire_again_timer.set_wait_time(1.5)
		if fire_again_timer.is_stopped():
			fire_again_timer.start()
	else:
		print_debug("No player position found! Did you check the scene tree?")

func _ready():
	setup_on_screen_timer()
	parent_node.has_non_queue_free_rotator = false
	_fire_rate_timer_setup()
	_fire_again_timer_setup()
	_setup_bullets()
	Events.connect("player_global_position", self, "_on_player_global_position")
	AudioManager.playSFX("UFO", 0.6, -20.0)

func _on_player_global_position(player_global_position):
	player_position = player_global_position

func _setup_bullets():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = bro_bear_bullet.instance()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		spawn_point.add_to_group("static_bro_bear_bullets")
		spawn_point.speed = projectile_speed
		rotator.add_child(spawn_point)
	fire_rate_timer.set_wait_time(fire_rate_timer_wait_time)
	fire_rate_timer.start()

func get_spawn_height():
	return DataClasses.SpawnHeight.HIGH_ONLY

func _physics_process(delta):
	# haha what the fuck is the code below this even doing jesus christ
	if parent_node.global_position.x >= 1843:
		parent_node.position.x -= 200 * 1.25 * delta
	else:
		var new_rotation = rotator.rotation_degrees - rotate_speed * delta
		rotator.rotation_degrees = fmod(new_rotation, 360)
		if !allow_move_forward:
			path_follow.set_offset(path_follow.get_offset() + default_path_speed * delta)
	if allow_move_forward:
		parent_node.global_position.x -= 500.0 * 1.5 * delta
	
func get_class():
	return "StaticBroBear"
