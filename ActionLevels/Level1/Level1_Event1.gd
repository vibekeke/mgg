extends BaseLevelEvent

var bee_enemy = preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn")
var number_of_enemies_to_spawn = 20
var success_status : bool
onready var bee = get_node("%NewMisbeehave")

func _ready():
	bee.enable_movement(false)
	bee.disable_damage(true)
	bee.disable_touch_damage(true)
	MggDialogue.connect("dialogue_finished_with_status", self, "_on_emit_dialogue_finished_with_status")
	Events.connect("back_to_stage_from_dialogue_intro", self, "_on_back_to_stage_from_dialogue_intro")

func _on_Level1_Event1_visibility_changed():
	if self.visible:
		if is_instance_valid(bee):
			bee.enable_movement(true)

func _on_back_to_stage_from_dialogue_intro():
	if !success_status:
		print("here come the bees, bees, bees, bees")
		for _index in range(0, 20):
			print("bee")
			var bee_instance = bee_enemy.instance()
			enemy_spawner_node.spawn_specific_enemy(bee_instance)

func _on_emit_dialogue_finished_with_status(_success_status: bool):
	success_status = _success_status
