extends Node

onready var upper_position = get_node("%Upper")
onready var middle_position = get_node("%Middle")
onready var lower_position = get_node("%Lower")
onready var new_spawn_timer = get_node("%NewSpawnTimer")
onready var fade_out_kill_tween = get_node("%FadeOutKillTween")

var level_name := ""
var rng = RandomNumberGenerator.new()

export (NodePath) var level
onready var level_node = get_node(level)

export var spawning_enabled := true
export var time_to_spawn := 1.0

var total_time_passed := 0.0

var max_number_of_on_screen_enemies = 6

var level_enemy_list := {
	'LevelTest': {
		'SneakySnake': preload("res://ActionLevels/LevelCreator/Enemies/NewSneakySnake/NewSneakySnake.tscn"), 
		'Misbeehave': preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn"), 
		'Gunnerfly': preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerfly/NewGunnerfly.tscn"), 
		'GunnerflyWithGun': preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerflyWithGun/NewGunnerflyWithGun.tscn"), 
		'BroBear': preload("res://ActionLevels/LevelCreator/Enemies/NewBroBear/NewBroBear.tscn"), 
		'BroBun': preload("res://ActionLevels/LevelCreator/Enemies/NewBroBun/NewBroBun.tscn"), 
		'OurGuy': preload("res://ActionLevels/LevelCreator/Enemies/NewOurGuy/NewOurGuy.tscn")
		},
	'Level1': {
		'SneakySnake': preload("res://ActionLevels/LevelCreator/Enemies/NewSneakySnake/NewSneakySnake.tscn"), 
		'Misbeehave': preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn"), 
		'Gunnerfly': preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerfly/NewGunnerfly.tscn"), 
		'GunnerflyWithGun': preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerflyWithGun/NewGunnerflyWithGun.tscn"), 
		'BroBear': preload("res://ActionLevels/LevelCreator/Enemies/NewBroBear/NewBroBear.tscn"), 
		'BroBun': preload("res://ActionLevels/LevelCreator/Enemies/NewBroBun/NewBroBun.tscn"), 
		'OurGuy': preload("res://ActionLevels/LevelCreator/Enemies/NewOurGuy/NewOurGuy.tscn")
		},
	'Level2': [],
	'Level3': []
}

var onscreen_enemy_number := {
	'SneakySnake': INF,
	'Misbeehave': INF,
	'Gunnerfly': INF,
	'GunnerflyWithGun': 1,
	'BroBear': 1,
	'BroBun': 2,
	'OurGuy': 3
}

var enemy_queue = []

func _ready():
	rng.randomize()
	level_name = level_node.name
	Events.connect("enemy_spawner_enabled", self, "_on_enemy_spawner_enabled")
	Events.connect("enemy_spawner_difficulty", self, "_on_enemy_spawner_difficulty")
	Events.connect("kill_spawned_enemies", self, "_on_kill_spawned_enemies")

func _process(delta):
	total_time_passed += delta

func spawn_height_to_position(spawn_height) -> Vector2:
	var position_to_spawn = []
	if DataClasses.EnemySpawnHeight.LOWER in spawn_height:
		 position_to_spawn.append(lower_position.global_position)
	if DataClasses.EnemySpawnHeight.MIDDLE in spawn_height:
		 position_to_spawn.append(middle_position.global_position)
	if DataClasses.EnemySpawnHeight.UPPER in spawn_height:
		position_to_spawn.append(upper_position.global_position)
	return position_to_spawn[randi() % position_to_spawn.size()]

func get_spawnable_enemy_list():
	var enemies_not_to_spawn = []
	var all_enemies = get_all_enemies_for_level()
	var spawnable_enemies = {}
	var valid_enemies = valid_enemies()
	for enemy in valid_enemies:
		var enemy_name = enemy.get_enemy_name()
		if onscreen_enemy_number.has(enemy_name):
			if get_number_of_enemies_on_screen(enemy_name) >= onscreen_enemy_number[enemy_name]:
				enemies_not_to_spawn.append(enemy_name)
	for enemy_name in all_enemies.keys():
		if !enemies_not_to_spawn.has(enemy_name):
			spawnable_enemies[enemy_name] = all_enemies[enemy_name]
	return spawnable_enemies

func get_number_of_enemies_on_screen(enemy_name: String) -> int:
	var count = 0
	for enemy in valid_enemies():
		if enemy.get_enemy_name() == enemy_name:
			count += 1
	return count

func get_all_enemies_for_level() -> Dictionary:
	return level_enemy_list[level_name]

func spawn_specific_enemy(enemy_node_instance):
	for node in enemy_node_instance.get_children():
		if "spawn_height_component" in node.get_groups():
			enemy_node_instance.global_position = spawn_height_to_position(node.spawn_height)
			level_node.add_child(enemy_node_instance)

func spawn_enemies():
	if spawning_enabled:
		var spawnable_enemies = get_spawnable_enemy_list().values()
		var enemy_to_spawn = spawnable_enemies[randi() % spawnable_enemies.size()]
		var enemy_to_spawn_instance = enemy_to_spawn.instance()
		for node in enemy_to_spawn_instance.get_children():
			if "spawn_height_component" in node.get_groups():
				enemy_to_spawn_instance.global_position = spawn_height_to_position(node.spawn_height)
				print("spawn offsets x: ", enemy_to_spawn_instance.x_spawn_offset, " y: ", enemy_to_spawn_instance.y_spawn_offset)
				print("enemy height before offset ", enemy_to_spawn_instance.global_position)
				enemy_to_spawn_instance.global_position.x += enemy_to_spawn_instance.x_spawn_offset
				enemy_to_spawn_instance.global_position.y += enemy_to_spawn_instance.y_spawn_offset
				print("enemy height after offset ", enemy_to_spawn_instance.global_position)
		enemy_queue.append(enemy_to_spawn_instance)
		enemy_to_spawn_instance.connect("tree_exiting", self, "_on_enemy_exiting_tree")
		level_node.add_child(enemy_to_spawn_instance)

func valid_enemies() -> Array:
	var valid_enemies = []
	for enemy in enemy_queue:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)
	return valid_enemies

func _on_enemy_exiting_tree():
	enemy_queue = valid_enemies()

func _on_NewSpawnTimer_timeout():
	if enemy_queue.size() < max_number_of_on_screen_enemies:
		spawn_enemies()

func _on_enemy_spawner_enabled(enabled):
	spawning_enabled = enabled

func _on_enemy_spawner_difficulty(time_to_spawn, max_enemies):
	max_number_of_on_screen_enemies = max_enemies
	new_spawn_timer.wait_time = time_to_spawn

func _on_kill_spawned_enemies():
	for enemy in valid_enemies():
		if is_instance_valid(enemy):
			fade_out_kill_tween.interpolate_property(enemy, "modulate", enemy.modulate, Color(1,1,1,0.0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	fade_out_kill_tween.start()

func _on_FadeOutKillTween_tween_completed(object, key):
	if is_instance_valid(object):
		object.queue_free()
