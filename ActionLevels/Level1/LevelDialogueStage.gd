extends Node2D

onready var tween = get_node("%Tween")
onready var player = get_node("%Player")
onready var spotlight_one = get_node("%Spotlight")
onready var spotlight_two = get_node("%Spotlight2")

onready var dumb_enemy_list = {
	'Misbeehave': preload("res://ActionLevels/LevelCreator/DumbEnemies/DumbMisbeehave/DumbMisbeehave.tscn")
}

func _ready():
	player.global_position = Vector2(-215, 749)
	spotlight_one.visible = false
	spotlight_two.visible = false

func load_enemy(enemy_name):
	print("enemy name is ", enemy_name)
	var enemy_node = dumb_enemy_list[enemy_name].instance()
	enemy_node.global_position = Vector2(2129, 819)
	self.add_child(enemy_node)
	tween.interpolate_property(enemy_node, "global_position", enemy_node.global_position, Vector2(1472, 819), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	enemy_node.modulate = Color(0, 0, 0, 1.0)
	player.modulate = Color(0, 0, 0, 1.0)
	tween.interpolate_property(player, "global_position", player.global_position, Vector2(400, 749), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if enemy_node.has_method("disable_components"):
		enemy_node.disable_components()
	tween.start()
	yield(tween, "tween_all_completed")
	spotlight_one.visible = true
	spotlight_two.visible = true
	enemy_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	player.modulate = Color(1.0, 1.0, 1.0, 1.0)
