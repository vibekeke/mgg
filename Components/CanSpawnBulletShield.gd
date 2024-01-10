extends Node

const star_bullet = preload("res://ActionLevels/LevelCreator/Enemies/EnemyBullets/StarBullet.tscn")
const bullet_rotator = preload("res://ActionLevels/LevelCreator/Enemies/EnemyBullets/BulletRotator.tscn")
onready var bullet_rotator_instance = bullet_rotator.instance()
onready var shoot_timer = get_node("%ShootTimer")

export (NodePath) var visibility_notifier
onready var visibility_notifier_node = get_node(visibility_notifier)

export var shoots_bullets := true
export var bullets_die_with_parent := false

export (int) var rotate_speed = 100
export (int) var spawn_point_count = 8
export (int) var radius = 135
export (float) var time_to_fire = 2.0
export (NodePath) var node_rotator_position
onready var node_rotator_position_node = get_node(node_rotator_position)
var spawned_bullets = []

func _ready():
	bullet_rotator_instance.global_position = node_rotator_position_node.global_position
	bullet_rotator_instance.node_to_follow = node_rotator_position_node
	node_rotator_position_node.connect("tree_exiting", self, "_on_node_rotator_tree_exiting")
	node_rotator_position_node.connect("tree_exited", self, "_on_node_rotator_tree_exited")
	visibility_notifier_node.connect("screen_entered", self, "_on_screen_entered")
	get_tree().current_scene.call_deferred("add_child", bullet_rotator_instance)
	shoot_timer.wait_time = time_to_fire
	_setup_bullets()
	
func _on_node_rotator_tree_exiting():
	if bullets_die_with_parent:
		kill_bullets()

func _on_node_rotator_tree_exited():
	shoot_timer.queue_free()
	shoot_bullets()

func kill_bullets():
	for bullet in spawned_bullets:
		if is_instance_valid(bullet):
			bullet.queue_free()
		
func _setup_bullets():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = star_bullet.instance()
		spawned_bullets.append(spawn_point)
		spawn_point.enabled = false
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.global_position = node_rotator_position_node.global_position
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		bullet_rotator_instance.add_child(spawn_point)

func _on_screen_entered():
	shoot_timer.start()
	
func shoot_bullets():
	if shoots_bullets:
		for bullet in spawned_bullets:
			if is_instance_valid(bullet):
				bullet.set_enabled(true)
		
func _on_ShootTimer_timeout():
	shoot_bullets()
