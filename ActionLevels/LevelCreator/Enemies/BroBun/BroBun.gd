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
onready var line_area = parent_node.get_node("LineArea")

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
	orbit = orbit + delta

func _on_fire_rate_timeout():
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

func generate_bullet_shield():
	pass

func _ready():
	test_sprite.global_position.y = parent_node.global_position.y + 150
	line_area.connect("area_entered", self, "_on_line_area_entered")

func _on_line_area_entered(entered_by):
	print("entered by ", entered_by)

func rotate_around_better(delta, a: Vector2, b: Vector2, object: Object):
	orbit += 1
	var c = Vector2(b.x - a.x, b.y - a.y)
	var c_hat = Vector2(c.x * cos(orbit) - c.y * sin(orbit), c.x * sin(orbit) + c.y * cos(orbit))
	object.global_position = c_hat
	
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
	pass
	
func _physics_process(delta):
	# spawn bullet one at a time then shoot out
	#rotate_around(delta, test_sprite, 150, 2, parent_node.global_position)
	rotate_around_better(delta, test_sprite.position, parent_node.global_position, test_sprite)
	

func get_class():
	return "BroBun"
