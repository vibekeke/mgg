extends Node

onready var new_spawn_timer = get_node("%NewSpawnTimer")

export (int) var max_platforms_on_screen = 3
export (float) var seconds_platform_spawn_frequency = 2.0
export (Vector2) var default_platform_spawn_position = Vector2(2000, 410)
export (float) var platform_speed = 500.0

var level_name := ""
var rng = RandomNumberGenerator.new()
export (NodePath) var level
onready var level_node = get_node(level)

export var spawning_enabled := true
export var time_to_spawn := 1.0

var total_time_passed := 0.0
var platform_queue = []

var level_platform_list := {
	'LevelTest': [
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LongTallPlatform.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform1.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform2.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform3.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/TallPlatform.tscn"),
	],
	'Level1': [
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LongTallPlatform.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform1.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform2.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform3.tscn"),
		preload("res://ActionLevels/LevelCreator/Obstacles/Forest/TallPlatform.tscn"),
	],
	'Level2': [],
	'Level3': []
}

func _ready():
	rng.randomize()
	level_name = level_node.name
	Events.connect("platform_spawner_enabled", self, "_on_platform_spawner_enabled")
	Events.connect("platform_spawn_number", self, "_on_platform_spawn_number")
	Events.connect("kill_spawned_platforms", self, "_on_kill_spawned_platforms")

func _process(delta):
	total_time_passed += delta


func spawn_platforms():
	if spawning_enabled:
		var platforms_for_level = level_platform_list[level_name]
		var spawnable_platform = platforms_for_level[randi() % platforms_for_level.size()]
		var spawnable_platform_instance = spawnable_platform.instance()
		spawnable_platform_instance.global_position = default_platform_spawn_position
		spawnable_platform_instance.scroll_speed = platform_speed
		platform_queue.append(spawnable_platform_instance)
		spawnable_platform_instance.connect("tree_exiting", self, "_on_platform_exiting_tree")
		print("spawning platform", spawnable_platform_instance)
		level_node.add_child(spawnable_platform_instance)
		new_spawn_timer.wait_time = rng.randf_range(time_to_spawn + 1.0, time_to_spawn + 2.5)

func valid_platforms() -> Array:
	var valid_platforms = []
	for platform in platform_queue:
		if is_instance_valid(platform):
			valid_platforms.append(platform)
	return valid_platforms

func _on_platform_spawner_enabled(enabled):
	spawning_enabled = enabled

func _on_platform_exiting_tree():
	platform_queue = valid_platforms()


func _on_NewSpawnTimer_timeout():
	if platform_queue.size() < max_platforms_on_screen:
		spawn_platforms()


func _on_kill_spawned_platforms():
	for platform in valid_platforms():
		if is_instance_valid(platform):
			platform.queue_free()
