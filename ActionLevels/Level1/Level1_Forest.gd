extends Node2D

signal level_start
signal scene_fully_loaded

onready var spawn_paths = $SpawnPaths
onready var background_music = $BackgroundMusic
onready var boss_music = $BossMusic
onready var level_background = get_node("%LevelBackground")
onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var level_start_display = get_node("%LevelStartDisplay")
export var boss_background : PackedScene
export var mute_audio = false # temporary

func _ready():
	level_start_display.connect("confirm_level_start", self, "_on_confirm_level_start")
	enemy_spawner.stop_enemy_spawner()
	platform_spawner.stop_platform_spawner()
	Events.connect("boss_spawned", self, "_on_boss_spawn")
	Events.emit_signal("background_moving_enabled", false)
	Events.emit_signal("player_standing", true)

	var num_spawn_points = spawn_paths.get_curve().get_point_count()
	var spawn_point_dictionary = {}
	var spawn_point_heights = [DataClasses.SpawnHeight.HIGH_ONLY, DataClasses.SpawnHeight.MED_ONLY, DataClasses.SpawnHeight.LOW_ONLY]
	var spawn_point_array = []
	for x in range(0, num_spawn_points):
		spawn_point_array.append(spawn_paths.get_curve().get_point_position(x))
		spawn_point_dictionary[spawn_point_heights[x]] = spawn_paths.get_curve().get_point_position(x)
	Events.emit_signal("level_spawn_points", spawn_point_dictionary)
	if !mute_audio:
		if !background_music.is_playing():
			background_music.play()
	
	# Wait for all events to finish loading
	call_deferred("_wait_for_events_to_load")

func add_initial_background_element():
	if boss_background != null:
		var _boss_background = boss_background.instance()
		_boss_background.position = Vector2(0, 450)
		level_background.get_node_or_null('SkyBackground').add_child(_boss_background)

func _on_boss_spawn():
	if !mute_audio:
		background_music.stop()
		boss_music.play()

func _wait_for_events_to_load():
	print("Level1_Forest: Waiting for all events to finish loading...")
	
	# Get all LevelEvent children
	var events_manager = get_node("%LevelEventsManager")
	var level_events = []
	
	for child in events_manager.get_children():
		if child is LevelEvent:
			level_events.append(child)
			# Connect to their loading_complete signals
			if not child.is_connected("loading_complete", self, "_on_event_loading_complete"):
				child.connect("loading_complete", self, "_on_event_loading_complete")
	
	print("Level1_Forest: Found ", level_events.size(), " level events to wait for")
	
	# Check if any are already complete
	_check_all_events_complete()

func _on_event_loading_complete():
	print("Level1_Forest: An event finished loading, checking if all are complete...")
	_check_all_events_complete()

func _check_all_events_complete():
	var events_manager = get_node("%LevelEventsManager")
	var total_events = 0
	var completed_events = 0
	
	for child in events_manager.get_children():
		if child is LevelEvent:
			total_events += 1
			if child.get_loading_complete():
				completed_events += 1
			else:
				print("Level1_Forest: Still waiting for ", child.event_name)
	
	print("Level1_Forest: Events complete: ", completed_events, "/", total_events)
	
	if completed_events >= total_events and total_events > 0:
		print("Level1_Forest: All events loaded! Emitting scene_fully_loaded signal")
		Events.emit_signal("scene_fully_loaded")
	elif total_events == 0:
		# Fallback: no events found, emit immediately
		print("Level1_Forest: No events found, emitting scene_fully_loaded immediately")
		Events.emit_signal("scene_fully_loaded")

func _on_confirm_level_start():
	enemy_spawner.start_enemy_spawner()
	platform_spawner.start_platform_spawner()
	Events.emit_signal("background_moving_enabled", true)
	Events.emit_signal("player_standing", false)
	Events.emit_signal("fall_down_ui")
	self.emit_signal("level_start")
	add_initial_background_element()
