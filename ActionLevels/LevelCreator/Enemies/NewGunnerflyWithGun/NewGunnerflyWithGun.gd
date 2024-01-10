extends EnemyBase

onready var shoot_timer = get_node("%ShootTimer")
onready var stop_moving_timer = get_node("%StopMovingTimer")
onready var bullet_position = get_node("%BulletPosition")
onready var can_move_single_direction = get_node("%CanMoveSingleDirection")
var bullet = preload("res://ActionLevels/LevelCreator/Enemies/EnemyBullets/StarBullet.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	Events.connect("player_global_position", self, "_on_player_global_position")
	stop_moving_timer.wait_time = rng.randf_range(1.5, 2.5)
	stop_moving_timer.start()

func _on_ShootTimer_timeout():
	var bullet_instance = bullet.instance()
	bullet_instance.global_position = bullet_position.global_position
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

func _on_StopMovingTimer_timeout():
	can_move_single_direction.is_moving = false

func _on_player_global_position(player_global_position):
	if self.global_position.x < player_global_position.x:
		can_move_single_direction.is_moving = true
