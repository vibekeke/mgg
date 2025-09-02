extends Node2D

signal level_start

onready var spawn_paths = $SpawnPaths
onready var background_music = $BackgroundMusic
onready var boss_music = $BossMusic
onready var level_background = get_node("%LevelBackground")
onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var level_start_display = get_node("%LevelStartDisplay")
export var boss_background : PackedScene
export var mute_audio = false

func _ready():
	level_start_display.connect("confirm_level_start", self, "_on_confirm_level_start")
	enemy_spawner.stop_enemy_spawner()
	platform_spawner.stop_platform_spawner()
	Events.connect("boss_spawned", self, "_on_boss_spawn")
	Events.emit_signal("background_moving_enabled", false)
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
	if !mute_audio:
		if !background_music.is_playing():
			background_music.play()

func add_initial_background_element():
	if boss_background != null:
		var _boss_background = boss_background.instance()
		_boss_background.position = Vector2(0, 450)
		level_background.get_node_or_null('SkyBackground').add_child(_boss_background)

func _on_boss_spawn():
	if !mute_audio:
		background_music.stop()
		boss_music.play()

func _on_confirm_level_start():
	enemy_spawner.start_enemy_spawner()
	platform_spawner.start_platform_spawner()
	Events.emit_signal("background_moving_enabled", true)
	Events.emit_signal("player_standing", false)
	Events.emit_signal("fall_down_ui")
	self.emit_signal("level_start")
	add_initial_background_element()
