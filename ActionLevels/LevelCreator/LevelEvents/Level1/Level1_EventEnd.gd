extends LevelEvent

@export var level1_event_end_dialog : Resource
@onready var enemy_spawner = get_node("%EnemySpawner")
@onready var platform_spawner = get_node("%PlatformSpawner")
@onready var collected_dogs = []
var start_event_timer = Timer.new()
@export var debug_mode : bool = false

@onready var win_popup = preload("res://Menus/YouWinPopup.tscn")
@onready var completed_pacifist : bool = false;
@onready var you_win_shown : bool = false

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", Callable(self, "_on_dialogue_box_finished"))
	self.add_child(start_event_timer)
	event_number = 99
	event_name = 'Level1_EventEnd'
	Events.connect("collected_dog", Callable(self, "_on_collected_dog"))
	Events.connect("level_event_complete", Callable(self, "_on_level_event_complete"))
	Events.connect("pacifist_successful", Callable(self, "_on_pacifist_successful"))
	if debug_mode:
		print("event start debug")
		event_start()

func _on_pacifist_successful():
	completed_pacifist = true

func _on_dialogue_box_finished(node_id):
	if self.get_instance_id() == node_id and !you_win_shown:
		you_win_shown = true
		var new_instance = win_popup.instantiate()
		add_child(new_instance)

	#if self.get_instance_id() == node_id:
	#	yield(get_tree().create_timer(2.0), "timeout")
	#	end_event()

func _on_collected_dog(dog_breed):
	if !collected_dogs.has(dog_breed):
		collected_dogs.append(dog_breed)

func _on_wait_after_stopping_spawner_timer():
	event_start()

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 6:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", Callable(self, "trigger"))
		start_event_timer.set_wait_time(1.0)
		start_event_timer.set_one_shot(true)
		start_event_timer.start()

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner.enemy_spawner_is_running():
		enemy_spawner.stop_enemy_spawner()
	if platform_spawner.platform_spawner_is_running():
		platform_spawner.stop_platform_spawner()
	event_start()
	
func display_pacifist_dialogue():
	MggDialogue.create_dialogue_balloon(
		"level1_event_end_pacifist",
		level1_event_end_dialog,
		self.get_instance_id(),
		DataClasses.Placement.LOWER,
		DataClasses.CharacterPortrait.AngelIntense,
		Color(0.0, 0.42, 0.628, 0.5),
		Color(0.0, 0.0, 0.0, 0.25)
	)

func display_dialogue():
	MggDialogue.create_dialogue_balloon(
		"level1_event_end", 
		level1_event_end_dialog, 
		self.get_instance_id(), 
		DataClasses.Placement.LOWER, 
		DataClasses.CharacterPortrait.AngelHappy,
		Color(0.0, 0.42, 0.628, 0.5),
		Color(0.0, 0.0, 0.0, 0.25)
	)
	
func event_start() -> void:
	Events.emit_signal("disable_player_action", true)
	Events.emit_signal("player_standing", true)
	Events.emit_signal("background_moving_enabled", false)
	await get_tree().create_timer(2.0).timeout
	if StatsTracker.current_level_stats:
		StatsTracker.current_level_stats.last_run_completed = true
		StatsTracker.calculate_level1_challenges()
	else:
		print_debug("Couldn't find any level stats, something weird happened")
	if completed_pacifist:
		display_pacifist_dialogue()
	else:
		display_dialogue()


func end_event() -> void:
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	Events.emit_signal("transition_to_scene", "Intro", true)
