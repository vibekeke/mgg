extends Node2D

signal level_start

onready var spawn_paths = $SpawnPaths
onready var level_background = get_node("%LevelBackground")
onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var level_start_display = get_node("%LevelStartDisplay")
onready var vhs_filter = get_node("%VHS")
export var boss_background : PackedScene
export var mute_audio = false
export var level1_event1_dialog : Resource

export var dog_completion_popup : PackedScene

var fun_value : float = 0.0
var first_run : bool 

func _ready():
	randomize()
	
	var level_stats : Resource = LevelStats.new()
	level_stats.level_name = 'Level1_Forest'
	level_stats.level_number = 1
	level_stats.level_started = true
	level_stats.reset_all()
	StatsTracker.set_current_level(level_stats)

	fun_value = rand_range(0, 10)
	first_run = Events.first_time_playing
	ScoreManager.reset_level_score()
	Events.set_vhs_shader(Events.vhs_filter_state_unpaused, vhs_filter)
	level_start_display.connect("confirm_level_start", self, "_on_confirm_level_start")
	enemy_spawner.stop_enemy_spawner()
	platform_spawner.stop_platform_spawner()
	Events.connect("boss_spawned", self, "_on_boss_spawn")
	Events.connect("collected_all_dogs", self, "_on_all_dogs_collected")
	Events.emit_signal("background_moving_enabled", false)
	Events.emit_signal("player_invincible", true)
	Events.emit_signal("player_standing", true)
	Events.COLLECTED_DOGS = {}

	var num_spawn_points = spawn_paths.get_curve().get_point_count()
	var spawn_point_dictionary = {}
	var spawn_point_heights = [DataClasses.SpawnHeight.HIGH_ONLY, DataClasses.SpawnHeight.MED_ONLY, DataClasses.SpawnHeight.LOW_ONLY]
	var spawn_point_array = []
	for x in range(0, num_spawn_points):
		spawn_point_array.append(spawn_paths.get_curve().get_point_position(x))
		spawn_point_dictionary[spawn_point_heights[x]] = spawn_paths.get_curve().get_point_position(x)
	Events.emit_signal("level_spawn_points", spawn_point_dictionary)
	AudioManager.play_music("level1")
	

func add_initial_background_element():
	if boss_background != null:
		var _boss_background = boss_background.instance()
		_boss_background.position = Vector2(0, 450)
		level_background.get_node_or_null('SkyBackground').add_child(_boss_background)

func _on_boss_spawn():
	AudioManager.play_music("level1_boss")

func _on_confirm_level_start():
	AudioManager.playSFX("ui_confirm")
	enemy_spawner.start_enemy_spawner()
	platform_spawner.start_platform_spawner()
	Events.emit_signal("background_moving_enabled", true)
	Events.emit_signal("player_standing", false)
	Events.emit_signal("player_invincible", false)
	Events.emit_signal("fall_down_ui")
	self.emit_signal("level_start")
	add_initial_background_element()

func _on_all_dogs_collected():
	if not Events.dogs_complete:
		var new_instance = dog_completion_popup.instance()
		get_tree().current_scene.add_child(new_instance)
	Events.dogs_complete = true
	
