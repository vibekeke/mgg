extends Node2D

onready var death_explosion = preload("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/BaseEnemyExplosion.tscn")

onready var area2d = $Path2D/EnemyFollower/Area2D
onready var sprite = $Path2D/EnemyFollower/Area2D/AnimatedSprite
onready var collision_shape = $Path2D/EnemyFollower/Area2D/CollisionShape2D
onready var follow_path = $Path2D/EnemyFollower

export (float) var initial_speed

onready var queue_free_timer = Timer.new()

func _ready():
	area2d.connect("area_entered", self, "_on_call_area_entered")
	queue_free_timer.connect("timeout", self, "_on_death_cleanup")

func death_cleanup():
	queue_free_timer.set_wait_time(1)
	add_child(queue_free_timer)
	queue_free_timer.start()


func _on_death_cleanup():
	queue_free()

func call_death():
	collision_shape.disabled = true
	var death_explosion_node = death_explosion.instance()
	death_explosion_node.position = area2d.position
	death_explosion_node.set_one_shot(true)
	area2d.add_child(death_explosion_node)
	sprite.visible = false
	death_cleanup()

func _on_call_area_entered(area):
	if area.name == "GunshotArea2D":
		call_deferred("call_death")

func _physics_process(delta):
	follow_path.set_offset(follow_path.get_offset() + initial_speed * delta)
