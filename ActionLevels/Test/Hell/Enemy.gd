extends Node2D

#const bullet_scene = preload("res://ActionLevels/Test/Hell/Bullet.tscn")
const bullet_scene = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBirdProjectile.tscn")
onready var shoot_timer = $ShootTimer
onready var rotator = $Rotator

export var rotate_speed = 80
export var shoot_timer_wait_time = 0.2
export var spawn_point_count = 3
export var radius = 100

func _ready():
	var step = 2 * PI / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)
		
	shoot_timer.wait_time = shoot_timer_wait_time
	shoot_timer.start()

func _process(delta):
	var new_rotation = rotator.rotation_degrees + rotate_speed * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)

func _on_ShootTimer_timeout():
	for s in rotator.get_children():
		var bullet = bullet_scene.instance()
		get_tree().get_root().add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
