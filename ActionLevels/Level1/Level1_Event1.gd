extends BaseLevelEvent

var bee_enemy = preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn")
var number_of_enemies_to_spawn_background = 20
var success_status : bool
onready var talking_bee = get_node("%NewMisbeehave")
onready var background_for_bees = self.level_background_node
export var test_run := false
var background_bees_finished := false
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

func enable_background_bees(_bee, speed: int):
	_bee.modulate = Color(0,0,0,1.0)
	_bee.toggle_movement_direction(-1)
	_bee.enable_movement(true)
	_bee.disable_damage(true)
	_bee.disable_touch_damage(true)
	_bee.modify_speed(speed)


func _on_Level1_Event1_visibility_changed():
	if self.visible:
		if is_instance_valid(talking_bee):
			talking_bee.enable_movement(true)

func spawn_background_bees():
	for _x in range(0, number_of_enemies_to_spawn_background):
		print("making bee")
		var bee_enemy_instance = bee_enemy.instance()
		bee_enemy_instance.scale = Vector2(bee_enemy_instance.scale.x * -1, bee_enemy_instance.scale.y)
		bee_enemy_instance.global_position = Vector2(0,800)
		enable_background_bees(bee_enemy_instance, bee_speed)
		yield(get_tree().create_timer(0.1), "timeout")
		background_for_bees.get_back_forest_background_node().add_child(bee_enemy_instance)

func spawn_enemy_bees():
	for bee in self.get_children():
		if "event1_beeprop" in bee.get_groups():
			enable_bee_for_combat(bee, bee_speed)

func _on_back_to_stage_from_dialogue_intro():
	if !success_status:
		print("here come the bees, bees, bees, bees")
		yield(spawn_background_bees(), "completed")
		print("real bees comin")
		yield(get_tree().create_timer(2.0), "timeout")
		spawn_enemy_bees()
	else:
		print("get bee friend!")

func _on_emit_dialogue_finished_with_status(_success_status: bool):
	success_status = _success_status
