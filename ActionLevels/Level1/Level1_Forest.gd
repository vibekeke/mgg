extends Node2D

onready var spawn_paths = $SpawnPaths
onready var background_music = $BackgroundMusic
onready var boss_music = $BossMusic
onready var boss = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBird.tscn")
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
	if !mute_audio:
		if !background_music.is_playing():
			background_music.play()

func _on_level_complete():
	print("boss dead yay, transition to next level/area/cutscene/etc")

func _on_boss_spawn():
	if !mute_audio:
		background_music.stop()
		boss_music.play()
