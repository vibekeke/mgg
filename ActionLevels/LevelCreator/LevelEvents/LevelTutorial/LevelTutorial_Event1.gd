extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
export var enemy_to_spawn : PackedScene

onready var intro_and_jump_tutorial_dialog = Dialogic.start('TutorialChallenges/IntroAndJumpTutorial')
onready var float_tutorial_dialog = Dialogic.start('TutorialChallenges/FloatTutorial')
onready var slide_tutorial_dialog = Dialogic.start('TutorialChallenges/SlideTutorial')
onready var shoot_tutorial_dialog = Dialogic.start('TutorialChallenges/ShootTutorial')
onready var big_shot_tutorial_dialog = Dialogic.start('TutorialChallenges/BigShotTutorial')
onready var completed_tutorial_dialog = Dialogic.start('TutorialChallenges/CompleteTutorial')

onready var monitored_player = get_node("%RetroPlayer")

onready var bee_one = get_node("%Misbeehave")
onready var bee_two = get_node("%Misbeehave2")
onready var bee_three = get_node("%Misbeehave3")

var current_tutorial_task = ''
var last_completed_dialog = ''

var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()
var floated_duration_timer = Timer.new()

var orbs_touched = 0
var float_times = 0
var bees_shot = 0
var bees_shot_with_charge = 0

var jump_tutorial_orb_positions = [Vector2(1000, 500), Vector2(1500, 300), Vector2(1000, 500)]
var jump_tutorial_orb_directions = [1, 1, 0]

func _ready():

	# not the bees
	bee_one.initial_scroll_speed = 0
	bee_one.health_value = 2
	bee_one.has_invulnerability = true
	bee_one.can_wrap_around = true
	bee_one.death_by_collision_with_player = false

	bee_two.initial_scroll_speed = 0
	bee_two.health_value = 2
	bee_two.has_invulnerability = true
	bee_two.can_wrap_around = true
	bee_two.death_by_collision_with_player = false

	bee_three.initial_scroll_speed = 0
	bee_three.health_value = 3
	bee_three.has_invulnerability = true
	bee_three.can_wrap_around = true
	bee_three.death_by_collision_with_player = false

	intro_and_jump_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	float_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	slide_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	shoot_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	big_shot_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
	completed_tutorial_dialog.connect("dialogic_signal", self, "_on_dialog_complete")
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
	self.get_parent().add_child(slide_tutorial_dialog)
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
	var current_player_animation = monitored_player.current_animation()
	if current_player_animation == 'Slide':
		self.get_parent().add_child(shoot_tutorial_dialog)
		current_tutorial_task = 'shoot_challenge'

func shoot_challenge():
	var current_bees = get_tree().get_nodes_in_group("shoot_challenge")
	if len(current_bees) == 0:
		self.get_parent().add_child(big_shot_tutorial_dialog)
		current_tutorial_task = 'big_shot_challenge'

func big_shot_challenge():
	var current_bees = get_tree().get_nodes_in_group("big_shoot_challenge")
	if monitored_player.has_charge_shot == false:
		insta_charge()
	if len(current_bees) == 0:
		self.get_parent().add_child(completed_tutorial_dialog)
		current_tutorial_task = 'complete'

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
		"float":
			pass
		"slide":
			pass
		"shoot":
			move_bees_forward()
		"big_shot":
			move_final_bee_with_charge()
		"complete":
			end_tutorial()

func end_tutorial():
	Events.emit_signal("transition_to_scene", "Level1")

func insta_charge():
	for x in range(0, 15):
		Events.emit_signal("regular_enemy_death")

func move_final_bee_with_charge():
	insta_charge()
	monitored_player.has_charge_shot = true
	bee_three.initial_scroll_speed = 300
	bee_three.has_invulnerability = false

func move_bees_forward():
	bee_one.initial_scroll_speed = 300
	bee_one.has_invulnerability = false
	
	bee_two.initial_scroll_speed = 300
	bee_two.has_invulnerability = false

func _process(delta):
	if current_tutorial_task == 'jump_challenge' && last_completed_dialog == 'intro_and_jump':
		jump_challenge()
	if current_tutorial_task == 'float_challenge' && last_completed_dialog == 'float':
		float_challenge()
	if current_tutorial_task == 'slide_challenge' && last_completed_dialog == 'slide':
		slide_challenge()
	if current_tutorial_task == 'shoot_challenge' && last_completed_dialog == 'shoot':
		shoot_challenge()
	if current_tutorial_task == 'big_shot_challenge' && last_completed_dialog == 'big_shot':
		big_shot_challenge()
	if current_tutorial_task == 'complete' && last_completed_dialog == 'complete':
		pass

func end_event() -> void:
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
