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

# -1 = move right
# 1 = move left
func toggle_movement_direction(direction: int):
	if direction > 0:
		direction = 1
	elif direction == 0 or direction < 0:
		direction = -1
	var movement_node = get_node_by_name("CanMoveSingleDirection")
	if movement_node != null:
		movement_node.direction = direction


func disable_damage(status: bool):
	var damage_node = get_node_by_name("CanTakeDamage")
	if damage_node != null:
		damage_node.damage_disabled = status

func disable_touch_damage(status: bool):
	var damage_on_touch_node = get_node_by_name("CanDamagePlayerOnTouch")
	if damage_on_touch_node != null:
		damage_on_touch_node.is_disabled = status

func modify_speed(speed_value: int):
	var movement_node = get_node_by_name("CanMoveSingleDirection")
	if movement_node != null:
		movement_node.speed = speed_value

func disable_components_for_dialogue_stage():
	enable_movement(false)
	disable_damage(true)
	disable_touch_damage(true)
