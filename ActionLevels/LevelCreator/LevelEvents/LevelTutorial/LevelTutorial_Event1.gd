extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
export var enemy_to_spawn : PackedScene

onready var intro_and_jump_tutorial_dialog = Dialogic.start('TutorialChallenges/IntroAndJumpTutorial')
onready var float_tutorial_dialog = Dialogic.start('TutorialChallenges/FloatTutorial')

onready var monitored_player = get_node("%RetroPlayer")
var current_tutorial_task = ''
var last_completed_dialog = ''

var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()
var floated_duration_timer = Timer.new()

var orbs_touched = 0
var float_times = 0

var jump_tutorial_orb_positions = [Vector2(1000, 500), Vector2(1500, 300), Vector2(1000, 500)]
var jump_tutorial_orb_directions = [1, 1, 0]

func _ready():
	intro_and_jump_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	float_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	
	Events.connect("tutorial_element_touched", self, "_on_tutorial_element_touched")
	
	start_event_timer.set_name("LevelTutorial_Event1_start_timer")
	start_event_timer.connect("timeout", self, "trigger")
	start_event_timer.set_wait_time(0.5)
	start_event_timer.set_one_shot(true)
	
	wait_after_stopping_spawner_timer.set_name("LevelTutorial_Event1_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.set_wait_time(1.5)
	
	floated_duration_timer.set_name("LevelTutorial_Event1_float_duration_timer")
	floated_duration_timer.connect("timeout", self, "on_floated_duration_timer")
	floated_duration_timer.set_wait_time(3.5)
	floated_duration_timer.set_one_shot(true)
	
	self.add_child(start_event_timer)
	self.add_child(wait_after_stopping_spawner_timer)
	self.add_child(floated_duration_timer)
	
	start_event_timer.start()
	event_number = 1
	event_name = 'LevelTutorial_Event1'

func _on_tutorial_element_touched(element_id):
	if element_id == 1:
		orbs_touched += 1

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()
 
func move_orbs_to_position(current_challenge):
	if current_challenge == "intro_and_jump":
		var floating_orbs = get_tree().get_nodes_in_group("floating_orb")
		for x in range(0, len(floating_orbs)):
			floating_orbs[x].global_position = jump_tutorial_orb_positions[x]
			floating_orbs[x].movement_direction = jump_tutorial_orb_directions[x]

func jump_challenge():
	if orbs_touched >= 3:
		current_tutorial_task = 'float_challenge'
		orbs_touched = 0
		self.get_parent().add_child(float_tutorial_dialog)

func on_floated_duration_timer():
	floated_duration_timer.stop()
	print('starting slide challenge')
	current_tutorial_task = 'slide_challenge'

func float_challenge():
	var player_gravity_value = monitored_player.get_gravity()
	if player_gravity_value == monitored_player.get_float_gravity_value():
		if floated_duration_timer.is_stopped():
			floated_duration_timer.start()
		if floated_duration_timer.is_paused():
			floated_duration_timer.set_paused(false)
	else:
		floated_duration_timer.set_paused(true)
	
func slide_challenge():
	pass

func shoot_challenge():
	pass

func dog_challenge():
	pass

func big_shot_challenge():
	pass

func trigger() -> void: 
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func event_start() -> void:
	self.get_parent().add_child(intro_and_jump_tutorial_dialog)
	current_tutorial_task = 'jump_challenge'

func _on_dialog_complete(dialog_name) -> void:
	last_completed_dialog = dialog_name
	match dialog_name:
		"intro_and_jump":
			move_orbs_to_position(dialog_name)

func _process(delta):
	if current_tutorial_task == 'jump_challenge' && last_completed_dialog == 'intro_and_jump':
		jump_challenge()
	if current_tutorial_task == 'float_challenge' && last_completed_dialog == 'float':
		float_challenge()

func end_event() -> void:
	print("Ending event")
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
