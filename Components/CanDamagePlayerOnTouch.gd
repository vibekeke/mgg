extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)

export (NodePath) var enemy_area
onready var enemy_area_node = get_node(enemy_area)

export (bool) var death_by_collision_with_player = true

export (NodePath) var take_damage
onready var take_damage_node = get_node_or_null(take_damage)

var is_disabled := false

func _ready():
	enemy_area_node.connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hurtbox") and !is_disabled:
		if is_instance_valid(take_damage_node):
			# check if enemy is already dead first
			if !take_damage_node.death_called:
				Events.emit_signal("collided_with_player", 1)
			take_damage_node.take_damage()
		else:
			# in case root node is projectile
			Events.emit_signal("collided_with_player", 1)
