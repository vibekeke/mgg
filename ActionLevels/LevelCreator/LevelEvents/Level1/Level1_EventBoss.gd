extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var level_events_manager = get_node("%LevelEventsManager")
export var boss_warning_tape_path : NodePath
onready var boss_warning_tape = get_node(boss_warning_tape_path)
export var spawn_paths_path : NodePath
onready var spawn_paths : Path2D = get_node(spawn_paths_path)
onready var star_spawn_position = spawn_paths.get_spawn_points()[2]
export var star_collectible : PackedScene

export var spawn_collectible_to_node_path : NodePath
onready var spawn_collectible_to_node = get_node(spawn_collectible_to_node_path)

# timers
onready var start_event_timer = Timer.new()
onready var end_event_timer = Timer.new()
onready var wait_after_stopping_spawner_timer = Timer.new()
onready var boss_background_swoop_timer = Timer.new()
onready var collectible_spawn_timer = get_node("%CollectibleTimer")

onready var boss_background_to_spawn : Object = preload("res://ActionLevels/LevelCreator/LevelElements/BackgroundElements/Level1/BigBackground.tscn").instance()
onready var boss : PackedScene = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBird.tscn")
var background_boss_spawn_place = Vector2(-500, 700)
var background_boss_speed = 2000
var boss_instance = null
export var time_until_event_start = 3.0
export var debug_mode : bool = false
export var level1_event1_dialog : Resource
export var level1_event_pacificist_boss_dialogue : Resource

func star_spawn():
	var star_instance = star_collectible.instance()
	star_instance.scroll_speed = 250
	star_instance.global_position = star_spawn_position
	spawn_collectible_to_node.call_deferred("add_child", star_instance)

func _ready():
	boss_instance = boss.instance()
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	Events.connect("background_element_offscreen", self, "_on_background_element_offscreen")
	Events.connect("big_bird_boss_defeated", self, "_on_big_bird_boss_defeated")
	Events.connect("pacifist_successful", self, "_on_pacifist_successful")
	event_number = 6 # last level event
	boss_warning_tape.connect("warning_finished", self, "_on_warning_finished")
	event_name = "Level1_EventBoss"
	
	# Only use internal debug mode if LevelEventsManager isn't handling debug
	var is_manager_debug = level_events_manager.debug_trigger_event_number > 0
	if debug_mode and not is_manager_debug:
		_on_level_event_complete('dummy_event', 5)


func _on_dialogue_box_finished(node_id):
	if self.get_instance_id() == node_id:
		yield(get_tree().create_timer(2.0), "timeout")
		AudioManager.play_music("level1_boss")
		spawn_boss()
		collectible_spawn_timer.start()
	if node_id == 666:
		end_event()

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 5:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		if debug_mode:
			time_until_event_start = 0.1
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)

		end_event_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		end_event_timer.connect("timeout", self, "end_event")
		end_event_timer.set_wait_time(3.0)
		end_event_timer.set_one_shot(true)

		wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.set_wait_time(1.0)
		wait_after_stopping_spawner_timer.set_one_shot(true)

		self.add_child(start_event_timer)
		self.add_child(end_event_timer)
		self.add_child(wait_after_stopping_spawner_timer)
		
		start_event_timer.start()

func display_dialogue():
	MggDialogue.create_dialogue_balloon(
		"level1_event_boss", 
		level1_event1_dialog, 
		self.get_instance_id(), 
		DataClasses.Placement.LOWER, 
		DataClasses.CharacterPortrait.None,
		Color(0.0, 0.0, 0.0, 0.6),
		Color(0.3, 0.1, 0.5, 0.6),
		true,
		3.0
	)
	
func create_pacifist_dialogue():
	MggDialogue.create_dialogue_balloon(
		"level1_event_boss_pacifist_complete",
		level1_event1_dialog,
		666,
		DataClasses.Placement.LOWER,
		DataClasses.CharacterPortrait.None,
		Color(0.0, 0.0, 0.0, 0.6),
		Color(0.3, 0.1, 0.5, 0.6),
		false
	)

func trigger() -> void:
	if not wait_after_stopping_spawner_timer.is_inside_tree():
		setup_timers()
	if enemy_spawner != null and platform_spawner != null:
		Events.emit_signal("level_event_lock", event_name, event_number)
		enemy_spawner.stop_enemy_spawner()
		platform_spawner.stop_platform_spawner()
		wait_after_stopping_spawner_timer.start()

func setup_timers():
	end_event_timer.set_name(event_name + "_end_event_timer")
	end_event_timer.connect("timeout", self, "end_event")
	end_event_timer.set_wait_time(3.0)
	end_event_timer.set_one_shot(true)

	wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.set_wait_time(1.0)
	wait_after_stopping_spawner_timer.set_one_shot(true)

	self.add_child(end_event_timer)
	self.add_child(wait_after_stopping_spawner_timer)

func _on_wait_after_stopping_spawner_timer():
	wait_after_stopping_spawner_timer.stop()
	event_start()

func _on_background_element_offscreen(element_name):
	if element_name == DataClasses.Enemies.BIG_BIRD && level_events_manager.get_currently_running_event() == 6:
		if not boss_warning_tape.visible:
			AudioManager.fade_out_music(5)
			boss_warning_tape.visible = true
			boss_warning_tape.start_animation()
			# Disconnect to prevent multiple triggers
			Events.disconnect("background_element_offscreen", self, "_on_background_element_offscreen")

func spawn_boss():
	enemy_spawner.kill_non_boss_enemies()
	enemy_spawner._direct_spawn_boss_at_position(boss_instance, Vector2(1510, 620), 0)

func _on_warning_finished():
	display_dialogue()

func event_start() -> void:
	if boss_background_to_spawn != null:
		boss_background_to_spawn.scale.x = 0.65
		boss_background_to_spawn.scale.y = 0.65
		enemy_spawner.spawn_instanced_background_element(boss_background_to_spawn, 'BackForestBackground', background_boss_spawn_place, background_boss_speed)
		AudioManager.playSFX("BirdDescend", 1.0, -2)

func _on_big_bird_boss_defeated(death_position):
	AudioManager.fade_out_music(3)
	collectible_spawn_timer.stop()
	#TODO: Add ending dialogue?? + Defeated flag so it doesnt crash with the other ondialoguehwatever
	end_event()

func _on_pacifist_successful():
	Events.emit_signal("pausing_allowed", false)
	AudioManager.fade_out_music(3)
	collectible_spawn_timer.stop()
	Events.emit_signal("disable_player_action", true)
	Events.emit_signal("player_invincible", true)
	Events.emit_signal("player_standing", true)
	Events.emit_signal("background_moving_enabled", false)
	create_pacifist_dialogue()

func end_event() -> void:
	Events.emit_signal("player_invincible", true)
	start_event_timer.stop()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)


func _on_CollectibleTimer_timeout():
	star_spawn()
	collectible_spawn_timer.wait_time = randi() % 5 + 4
