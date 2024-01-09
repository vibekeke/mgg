extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)

export (NodePath) var enemy_area
onready var enemy_area_node = get_node(enemy_area)

export (NodePath) var enemy_sprite
onready var enemy_sprite_node = get_node(enemy_sprite)

onready var death_explosion = load("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/AnimatedEnemyExplosion.tscn")
export var health_value = 2

onready var damage_timer = get_node("%DamageTimer")

export (Color) var hurt_colour = Color(10,10,10,1)

signal enemy_dead(node_id, death_position)

var death_called := false
var damage_disabled := false

func _ready():
	enemy_area_node.connect("area_entered", self, "_on_area_entered")
	damage_timer.connect("timeout", self, "_on_damage_timer")

func call_death():
	if !death_called:
		death_called = true
		var death_global_position = enemy_area_node.global_position
		Events.emit_signal("regular_enemy_death")
		emit_signal("enemy_dead", self.get_instance_id(), death_global_position)
		var active_death_explosion = death_explosion.instance()
		active_death_explosion.add_to_group("death_explosion")
		active_death_explosion.connect("animation_finished", self, "_on_explosion_finished")
		#enemy_area_node.add_child(active_death_explosion)
		enemy_node.add_child(active_death_explosion)
		enemy_sprite_node.visible = false
		active_death_explosion.play("default", false)

func take_damage():
	damage_timer.start()
	enemy_sprite_node.modulate = hurt_colour
	health_value = health_value - 1


func _on_area_entered(area: Area2D):
	if area.is_in_group("damage_from_player") and health_value > 0 and !damage_disabled:
		take_damage()
	if health_value <= 0:
		call_death()

func _on_explosion_finished():
	enemy_node.queue_free()

func _on_damage_timer():
	enemy_sprite_node.modulate = Color(1,1,1,1)
	damage_timer.stop()
