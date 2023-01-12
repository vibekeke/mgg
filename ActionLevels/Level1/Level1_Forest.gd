extends Node2D

onready var spawn_paths = $SpawnPaths
onready var background_music = $BackgroundMusic
onready var boss_music = $BossMusic
onready var level_background = get_node("%LevelBackground")
export var boss_background : PackedScene

export var mute_audio = false # temporary

func _ready():
	Events.connect("boss_spawned", self, "_on_boss_spawn")
	Events.connect("level_complete", self, "_on_level_complete")
	var num_spawn_points = spawn_paths.get_curve().get_point_count()
	var spawn_point_dictionary = {}
	var spawn_point_heights = [DataClasses.SpawnHeight.HIGH_ONLY, DataClasses.SpawnHeight.MED_ONLY, DataClasses.SpawnHeight.LOW_ONLY]
	var spawn_point_array = []
	for x in range(0, num_spawn_points):
		spawn_point_array.append(spawn_paths.get_curve().get_point_position(x))
		spawn_point_dictionary[spawn_point_heights[x]] = spawn_paths.get_curve().get_point_position(x)
	Events.emit_signal("level_spawn_points", spawn_point_dictionary)
	add_initial_background_element()
	load_already_collected_dogs()
	if !mute_audio:
		if !background_music.is_playing():
			background_music.play()

func add_initial_background_element():
	if boss_background != null:
		var _boss_background = boss_background.instance()
		_boss_background.position = Vector2(0, 450)
		level_background.get_node_or_null('SkyBackground').add_child(_boss_background)

func load_already_collected_dogs():
	var collected_dogs_for_level_one = Events.COLLECTED_DOGS
	if collected_dogs_for_level_one.has('1'):
		for dog in collected_dogs_for_level_one.get('1', []):
			Events.emit_signal("collected_dog", dog)

func _on_level_complete():
	print("boss dead yay, transition to next level/area/cutscene/etc")

func _on_boss_spawn():
	if !mute_audio:
		background_music.stop()
		boss_music.play()
