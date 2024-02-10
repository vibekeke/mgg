extends CanvasLayer

onready var scene_transition_animation = get_node("%SceneTransitionAnimation")

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
	var level_instance = level.instance()
	current_level_name = level_instance.name
	print(level_instance.name)
	self.add_child(level.instance())
	scene_transition_animation.connect("before_bars_move_up", self, "_on_before_bars_move_up")
	scene_transition_animation.connect("dialogue_stage_finished", self, "_on_dialogue_stage_finished")

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
		if node.name == "LevelDialogueStage":
			if is_instance_valid(node):
				node.queue_free()
