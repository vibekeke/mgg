extends Node

class_name BroBun
onready var parent_node = self.get_parent()

onready var bunny_drop = false
const lil_bird_bullet = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBirdProjectile.tscn")
export (int) var rotate_speed = 10
export (int) var spawn_point_count = 8
export (float) var fire_rate_timer_wait_time = 0.2
export (int) var radius = 100
export (float) var projectile_speed = 100
onready var test_sprite = parent_node.get_node("TestSprite")

onready var spawned_bullets = 0
onready var fire_rate_timer = Timer.new()
onready var rotator = parent_node.get_node("Rotator")
onready var orbit = 0
onready var bullet_list = []
onready var rotate_lock_value

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

func _fire_rate_timer_setup():
	fire_rate_timer.set_name("boss_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	parent_node.add_child(fire_rate_timer)

func _process_bullet(delta):
	print("processing bullets in bullet list")
	orbit = orbit + delta
	print('orbit value ', orbit)
#	for bullet in bullet_list:
#		print(bullet.position)
#		bullet.position = Vector2(
#			sin(orbit * 2) * 100,
#			cos(orbit * 2) * 100
#		) + Vector2(100, 100)

func _on_fire_rate_timeout():
	#if spawned_bullets < spawn_point_count:
	if spawned_bullets < 1:
		for s in rotator.get_children():
			spawned_bullets = spawned_bullets + 1
			var bullet = lil_bird_bullet.instance()
			bullet.speed = 0
			get_tree().get_root().add_child(bullet)
			#bullet.position = s.global_position
			bullet.rotation = s.global_rotation
			bullet_list.append(bullet)
			break

func _ready():
	#_fire_rate_timer_setup()
	#_setup_bullets()
	test_sprite.global_position.y = parent_node.global_position.y + 150
	print(parent_node.global_position)
	pass

func rotate_around(delta, object: Object, radius: int, speed: int, point: Vector2):
	orbit += delta
	object.global_position = Vector2(cos(orbit * speed) * radius, sin(orbit * speed) * radius) + point
	if rotate_lock_value != null:
#		print('x ', abs(object.position.x - rotate_lock_value.x))
#		print('y ', abs(object.position.y - rotate_lock_value.y))
		if abs(object.position.x - rotate_lock_value.x) <= 2 and abs(object.position.y - rotate_lock_value.y) <= 2:
			print("one full rotation")
	if rotate_lock_value == null:
		rotate_lock_value = Vector2(object.position.x, object.position.y)


func _process(delta):
#	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
#	rotator.rotation_degrees = fmod(new_rotation, 360)
#	_process_bullet(delta)
	#test_sprite.global_position = parent_node.global_position
	#orbit += delta

	#test_sprite.global_position = Vector2(cos(orbit * 1) * 150, sin(orbit * 1) * 150) + parent_node.global_position
	pass
	
func _physics_process(delta):
	# spawn bullet one at a time then shoot out
	rotate_around(delta, test_sprite, 150, 2, parent_node.global_position)
#	if !parent_node.is_move_disabled:
#		if bunny_drop:
#			parent_node.position.y += 500 * delta
#		if parent_node.player_local_position != Vector2(0,0):
#			if parent_node.position.x - parent_node.player_local_position.x > 0:
#				var x_towards = parent_node.position.move_toward(parent_node.player_local_position, 500 * delta)
#				if abs(parent_node.position.x - parent_node.player_local_position.x) < 100:
#					bunny_drop = true
#					parent_node.position.y += parent_node.initial_scroll_speed * 5 * delta
#				parent_node.position.x = x_towards.x
#			else:
#				if bunny_drop == false:
#					parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BroBun"
