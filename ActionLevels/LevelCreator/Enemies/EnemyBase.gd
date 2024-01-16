class_name EnemyBase extends Node2D

export var enemy_name := ""

func get_enemy_name():
	return enemy_name

func get_node_by_name(node_name: String):
	for node in self.get_children():
		if node.name == node_name:
			return node
	return null

func enable_movement(status: bool):
	var movement_node = get_node_by_name("CanMoveSingleDirection")
	if movement_node != null:
		movement_node.is_moving = status

func disable_damage(status: bool):
	var damage_node = get_node_by_name("CanTakeDamage")
	if damage_node != null:
		damage_node.damage_disabled = status

func disable_touch_damage(status: bool):
	var damage_on_touch_node = get_node_by_name("CanDamagePlayerOnTouch")
	if damage_on_touch_node != null:
		damage_on_touch_node.is_disabled = status
