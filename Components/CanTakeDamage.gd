extends Node

@export var enemy: NodePath
@onready var enemy_node = get_node(enemy)

@export var enemy_area: NodePath
@onready var enemy_area_node = get_node(enemy_area)

@export var enemy_sprite: NodePath
@onready var enemy_sprite_node = get_node(enemy_sprite)

@export var visibility_notifier_path : NodePath
@onready var visibility_notifier : VisibleOnScreenNotifier2D = get_node(visibility_notifier_path)

@onready var death_explosion = load("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/AnimatedEnemyExplosion.tscn")
@export var health_value = 2

@onready var damage_timer = get_node("%DamageTimer")
@onready var off_screen_timer = get_node("%OffscreenTimer")

@export var hurt_colour: Color = Color(10,10,10,1)

signal took_damage(node_id)
signal enemy_dead(node_id, death_position)
signal enemy_return_to_pool(enemy_node)

@onready var damageable: bool = false

var death_called := false
var damage_disabled := false

func _ready():
	enemy_area_node.connect("area_entered", Callable(self, "_on_area_entered"))
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer"))
	visibility_notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	visibility_notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))

func call_death():
	if !death_called:
		death_called = true
		var death_global_position = enemy_area_node.global_position
		Events.emit_signal("regular_enemy_death")
		emit_signal("enemy_dead", self.get_instance_id(), death_global_position)
		var active_death_explosion = death_explosion.instantiate()
		active_death_explosion.scale = enemy_node.scale
		active_death_explosion.global_position = death_global_position
		active_death_explosion.add_to_group("death_explosion")
		active_death_explosion.connect("animation_finished", Callable(self, "_on_explosion_finished"))
		get_tree().current_scene.add_child(active_death_explosion)
		enemy_sprite_node.visible = false
		Events.emit_signal("score_popup_requested", "enemy", death_global_position)

func take_damage(damage_value: int):
	if damageable:
		damage_timer.start()
		enemy_sprite_node.modulate = hurt_colour
		health_value = health_value - damage_value
		emit_signal("took_damage", self.get_instance_id())
		if health_value <= 0 and !death_called:
			call_death()

func _on_area_entered(area: Area2D):
	if area.is_in_group("damage_from_player") and health_value > 0 and !damage_disabled:
		take_damage(area.damage)

func _on_screen_entered():
	print("SCREEN DEBUG: ", enemy_node.enemy_name, " entered screen, setting damageable=true")
	damageable = true

func _on_screen_exited():
	print("SCREEN DEBUG: ", enemy_node.enemy_name, " exited screen, starting off_screen_timer")
	off_screen_timer.start()

func _on_explosion_finished():
	emit_signal("enemy_return_to_pool", enemy_node)

func _on_damage_timer():
	enemy_sprite_node.modulate = Color(1,1,1,1)
	damage_timer.stop()
	
func _on_OffscreenTimer_timeout():
	print("SCREEN DEBUG: ", enemy_node.enemy_name, " offscreen timeout - returning to pool")
	damageable = false
	if !death_called:
		emit_signal("enemy_return_to_pool", enemy_node)
