extends Node2D
class_name PooledEnemy

@export var sprite_path : NodePath
@onready var sprite : AnimatedSprite2D = get_node(sprite_path)

@export var area2d_path : NodePath
@onready var area2d : Area2D = get_node(area2d_path)

@export var can_take_damage_path : NodePath
@onready var can_take_damage = get_node_or_null(can_take_damage_path)

@export var visibility_notifier_path : NodePath
@onready var visibility_notifier : VisibleOnScreenNotifier2D = get_node(visibility_notifier_path)

@export var spawn_height = DataClasses.SpawnHeight.ANY # (DataClasses.SpawnHeight)
@export var enemy_name : String
@export var initial_scroll_speed : float = 500
@export var droppables: Array[PackedScene]
@export var hurt_color: Color = Color(10,10,10,1)
@export var enemy_difficulty_tier : int
@export var death_explosion : PackedScene
@export var components: Array[PackedScene]

func reset_for_pool():
	visible = false
	set_physics_process(false)

	if can_take_damage:
		can_take_damage.death_called = false
		can_take_damage.damage_disabled = false
		can_take_damage.health_value = 2
	
	if sprite:
		sprite.visible = true
		sprite.modulate = Color(1,1,1,1)
	
	if area2d:
		area2d.monitoring = false
		area2d.monitorable = false
