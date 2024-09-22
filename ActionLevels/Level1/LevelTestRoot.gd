extends CanvasLayer

onready var scene_transition_animation = get_node("%SceneTransitionAnimation")
onready var level_start_animation = get_node("%LevelStartAnimation")
var dialogue_scene = load("res://ActionLevels/Level1/LevelDialogueStage.tscn")
var level = load("res://ActionLevels/Level1/LevelTest.tscn")
# var level_2 = load("res://ActionLevels/Level2/Level2.tscn")
# var level_3 = load("res://ActionLevels/Level3/Level3_City.tscn")
var current_level_name = ""
var dialogue_scene_finished := false

var level_list = {
	'LevelTest': level,
	'Level1': level,
	'Level2': null,
	'Level3': null
}

func _ready():
	level_start_animation.connect("level_start_animation_finished", self, "_on_level_start_animation_finished")
	scene_transition_animation.connect("before_bars_move_up", self, "_on_before_bars_move_up")
	scene_transition_animation.connect("dialogue_stage_finished", self, "_on_dialogue_stage_finished")
	#level_start_animation.level_start_animation()
	Events.emit_signal("background_moving_enabled", false)
	Events.emit_signal("platform_spawner_enabled", false)
	Events.emit_signal("enemy_spawner_enabled", false)
	load_level()
	
func _on_before_bars_move_up(enemy_name):
	var current_level_node = self.get_node(current_level_name)
	var dialogue_scene_instance = dialogue_scene.instance()
	dialogue_scene_instance.connect("scene_dialogue_finished", self, "_on_scene_dialogue_finished")
	self.add_child(dialogue_scene_instance)
	dialogue_scene_instance.load_enemy(enemy_name)

func _on_scene_dialogue_finished():
	for node in self.get_children():
		if node.name == "LevelDialogueStage":
			dialogue_scene_finished = true
	
func _on_dialogue_stage_finished():
	for node in self.get_children():
		if node.name == "LevelDialogueStage" and is_instance_valid(node):
			node.queue_free()

func load_level():
	var level_instance = level.instance()
	current_level_name = level_instance.name
	print(level_instance.name)
	self.add_child(level.instance())

func _on_level_start_animation_finished():
	Events.emit_signal("background_moving_enabled", true)
	Events.emit_signal("player_standing", false)
	Events.emit_signal("platform_spawner_enabled", true)
	Events.emit_signal("enemy_spawner_enabled", true)


func _on_LevelStartAnimationTimer_timeout():
	level_start_animation.level_start_animation()
	Events.emit_signal("fall_down_ui")
