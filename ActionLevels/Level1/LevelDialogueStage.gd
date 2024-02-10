extends Node2D

onready var tween = get_node("%Tween")
onready var spotlight_one = get_node("%Spotlight")
onready var spotlight_two = get_node("%Spotlight2")

signal scene_dialogue_finished

var dumb_actor_list = {
	'Player': load("res://ActionLevels/LevelCreator/DumbActors/DumbPlayer/DumbPlayer.tscn"),
	'Misbeehave': load("res://ActionLevels/LevelCreator/DumbActors/DumbMisbeehave/DumbMisbeehave.tscn")
}

func _ready():
	spotlight_one.visible = false
	spotlight_two.visible = false
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")

func load_enemy(enemy_name):
	var player_node = dumb_actor_list['Player'].instance()
	player_node.global_position = Vector2(-215, 749)
	var enemy_node = dumb_actor_list[enemy_name].instance()
	enemy_node.global_position = Vector2(2129, 819)
	self.add_child(player_node)
	self.add_child(enemy_node)
	tween.interpolate_property(enemy_node, "global_position", enemy_node.global_position, Vector2(1472, 819), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	enemy_node.modulate = Color(0, 0, 0, 1.0)
	player_node.modulate = Color(0, 0, 0, 1.0)
	tween.interpolate_property(player_node, "global_position", player_node.global_position, Vector2(400, 749), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# if enemy_node.has_method("disable_components"):
	# 	enemy_node.disable_components()
	tween.start()
	yield(tween, "tween_all_completed")
	spotlight_one.visible = true
	spotlight_two.visible = true
	enemy_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	player_node.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_dialogue_box_finished(node_id):
	print("dialogue finished in dialogue stage", node_id)
	emit_signal("scene_dialogue_finished")
