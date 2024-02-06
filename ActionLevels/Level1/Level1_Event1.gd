extends BaseLevelEvent

var bee_enemy = preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn")
var number_of_enemies_to_spawn = 20
var success_status : bool
onready var talking_bee = get_node("%NewMisbeehave")

var bee_speed := 1500

func _ready():
	for bee in self.get_children():
		if "event1_beeprop" in bee.get_groups():
			disable_bee_for_combat(bee)
	talking_bee.enable_movement(false)
	talking_bee.disable_damage(true)
	talking_bee.disable_touch_damage(true)
	MggDialogue.connect("dialogue_finished_with_status", self, "_on_emit_dialogue_finished_with_status")
	Events.connect("back_to_stage_from_dialogue_intro", self, "_on_back_to_stage_from_dialogue_intro")

func disable_bee_for_combat(_bee):
	_bee.enable_movement(false)
	_bee.disable_damage(true)
	_bee.disable_touch_damage(true)

func enable_bee_for_combat(_bee, speed: int):
	_bee.enable_movement(true)
	_bee.disable_damage(false)
	_bee.disable_touch_damage(false)
	_bee.modify_speed(speed)

func _on_Level1_Event1_visibility_changed():
	if self.visible:
		if is_instance_valid(talking_bee):
			talking_bee.enable_movement(true)

func _on_back_to_stage_from_dialogue_intro():
	if !success_status:
		print("here come the bees, bees, bees, bees")
		for bee in self.get_children():
			if "event1_beeprop" in bee.get_groups():
				enable_bee_for_combat(bee, bee_speed)

func _on_emit_dialogue_finished_with_status(_success_status: bool):
	success_status = _success_status
