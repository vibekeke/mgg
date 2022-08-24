extends Node2D

onready var death_explosion = preload("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/AnimatedEnemyExplosion.tscn")
export (float) var initial_speed
export (PackedScene) var base_enemy

onready var enemy_follower = $Path2D/PathFollow2D
onready var area2d = $Path2D/PathFollow2D/Area2D
onready var sprite = $Path2D/PathFollow2D/Area2D/AnimatedSprite
onready var collision_shape = $Path2D/PathFollow2D/Area2D/CollisionShape2D

onready var queue_free_timer = Timer.new()


func _ready():
	area2d.connect("area_entered", self, "_on_call_area_entered")
	area2d.connect("body_entered", self, "_on_call_body_entered")
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
	area2d.add_child(death_explosion_node)
	sprite.visible = false
	death_cleanup()

func _on_call_body_entered(body):
	if body.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)
		call_deferred("call_death")

func _on_call_area_entered(area):
	if area.name == "GunshotArea2D":
		call_deferred("call_death")

func _physics_process(delta):
	enemy_follower.offset += initial_speed * delta
