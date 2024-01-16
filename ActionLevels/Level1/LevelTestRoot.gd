extends CanvasLayer

onready var scene_transition_animation = get_node("%SceneTransitionAnimation")

var dialogue_scene = load("res://ActionLevels/Level1/LevelDialogueStage.tscn")
var level = load("res://ActionLevels/Level1/LevelTest.tscn")
var current_level_name = ""

var level_list = {
	'LevelTest': level,
	'Level1': level,
}

func _ready():
	var level_instance = level.instance()
	current_level_name = level_instance.name
	print(level_instance.name)
	self.add_child(level.instance())
	scene_transition_animation.connect("before_bars_move_up", self, "_on_before_bars_move_up")

func _on_before_bars_move_up(enemy_name):
	var current_level_node = self.get_node(current_level_name)
	# self.remove_child(current_level_node)
	current_level_node.visible = false
	var dialogue_scene_instance = dialogue_scene.instance()
	dialogue_scene_instance.connect("scene_dialogue_finished", self, "_on_scene_dialogue_finished")
	self.add_child(dialogue_scene_instance)
	dialogue_scene_instance.load_enemy(enemy_name)

func _on_scene_dialogue_finished():
	print("scene dialogue finished")
	scene_transition_animation.end_stage(true)
	
