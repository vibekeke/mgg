extends Node

onready var upper_position = get_node("%Upper")
onready var middle_position = get_node("%Middle")
onready var lower_position = get_node("%Lower")
onready var new_spawn_timer = get_node("%NewSpawnTimer")

onready var enemy_list = []
var rng = RandomNumberGenerator.new()

export (NodePath) var level
onready var level_node = get_node(level)

var total_time_passed := 0.0

var max_number_of_on_screen_enemies = 7

var level_enemy_list := {
	'Level1': [],
	'Level2': [],
	'Level3': []
}

var onscreen_enemy_number := {
	'SneakySnake': -1,
	'NewMisbeehave': -1,
	'NewGunnerfly': -1,
	'NewGunnerflyWithGun': 1
}

var enemy_queue = []

func _ready():
	rng.randomize()
	var snake = preload("res://ActionLevels/LevelCreator/Enemies/NewSneakySnake/NewSneakySnake.tscn")
	var bee = preload("res://ActionLevels/LevelCreator/Enemies/NewMisbeehave/NewMisbeehave.tscn")
	var gunnerfly = preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerfly/NewGunnerfly.tscn")
	var gunnerfly_with_gun = preload("res://ActionLevels/LevelCreator/Enemies/NewGunnerflyWithGun/NewGunnerflyWithGun.tscn")
	enemy_list.append(bee)
	enemy_list.append(snake)
	enemy_list.append(gunnerfly)
	enemy_list.append(gunnerfly_with_gun)

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
	var valid_enemies = valid_enemies()
	for enemy in valid_enemies:
		print(onscreen_enemy_number[enemy.name])

func spawn_enemies():
	get_spawnable_enemy_list()
	var enemy_to_spawn = enemy_list[randi() % enemy_list.size()]
	var enemy_to_spawn_instance = enemy_to_spawn.instance()
	for node in enemy_to_spawn_instance.get_children():
		if "spawn_height_component" in node.get_groups():
			enemy_to_spawn_instance.global_position = spawn_height_to_position(node.spawn_height)
	enemy_queue.append(enemy_to_spawn_instance)
	enemy_to_spawn_instance.connect("tree_exiting", self, "_on_enemy_exiting_tree")
	level_node.add_child(enemy_to_spawn_instance)

func valid_enemies():
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
