extends Node2D

export (int) var max_enemies_on_screen = 5
export (int) var max_platforms_on_screen = 3
export (float) var seconds_enemy_spawn_frequency = 1.0
export (float) var seconds_platform_spawn_frequency = 2.0
export (float) var seconds_spawn_unique_while_alive_frequency = 2.0
export (Vector2) var default_platform_spawn_position = Vector2(2000, 410)
onready var current_enemy_list : Array = []
export (Array, PackedScene) var first_tier_enemy_list
export (Array, PackedScene) var second_tier_enemy_list
export (Array, PackedScene) var third_tier_enemy_list
export (Array, PackedScene) var unique_enemy_list
export (Array, PackedScene) var platform_list
export (int) var default_scroll_speed = 500

onready var spawn_timer : Timer = Timer.new()
onready var spawn_unique_while_alive_timer : Timer = Timer.new()
onready var platform_spawn_timer : Timer = Timer.new()
onready var enemies_spawned : int = 0
onready var platforms_spawned : int = 0
onready var current_difficulty_tier : int = 1
onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
onready var spawn_paths = get_node("%SpawnPaths")
onready var level_background = get_node("%LevelBackground")
onready var level_events_manager = get_node("%LevelEventsManager")

var enemy_to_spawn = null
var unique_enemy_to_spawn = null
var platform_to_spawn = null
var spawn_points = {}

func _ready():
	rng.randomize()
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	if spawn_paths != null:
		_on_level_spawn_points(spawn_paths.get_spawn_points())
	spawn_timer.set_name("spawn_timer")
	spawn_timer.connect("timeout", self, "_spawn_enemy")
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))
	self.add_child(spawn_timer)
	spawn_timer.start()

	platform_spawn_timer.set_name("platform_spawn_timer")
	platform_spawn_timer.connect("timeout", self, "_spawn_platform")
	platform_spawn_timer.set_wait_time(seconds_platform_spawn_frequency + rng.randf_range(0.1, 1.0))
	self.add_child(platform_spawn_timer)
	platform_spawn_timer.start()
	
	spawn_unique_while_alive_timer.set_name("spawn_unique_while_alive_timer")
	spawn_unique_while_alive_timer.connect("timeout", self, "_spawn_unique_while_alive_enemy")
	spawn_unique_while_alive_timer.set_wait_time(seconds_spawn_unique_while_alive_frequency + rng.randf_range(1.0, 3.5))
	self.add_child(spawn_unique_while_alive_timer)
	spawn_unique_while_alive_timer.start()

func get_enemy_from_difficulty_tier():
	if current_difficulty_tier <= 1:
		current_enemy_list = first_tier_enemy_list
	elif current_difficulty_tier <= 2:
		current_enemy_list = first_tier_enemy_list + second_tier_enemy_list
	elif current_difficulty_tier >= 3:
		current_enemy_list = first_tier_enemy_list + second_tier_enemy_list + third_tier_enemy_list

func stop_enemy_spawner():
	platform_spawn_timer.stop()
	spawn_timer.stop()
	spawn_unique_while_alive_timer.stop()
	
func start_enemy_spawner():
	platform_spawn_timer.start()
	spawn_timer.start()
	spawn_unique_while_alive_timer.start()
	
func stop_platform_spawner():
	platform_spawn_timer.stop()

func start_platform_spawner():
	platform_spawn_timer.start()

func stop_spawning_enemies():
	spawn_timer.stop()

func start_spawning_enemies():
	spawn_timer.start()
	
func start_unique_enemy_spawner():
	spawn_unique_while_alive_timer.start()
	
func stop_unique_enemy_spawner():
	spawn_unique_while_alive_timer.stop()
	

func _on_level_spawn_points(_spawn_points):
	spawn_points = _spawn_points

func _on_regular_enemy_death():
	enemies_spawned -= 1
	
func _spawn_enemy():
	if enemies_spawned < max_enemies_on_screen:
		get_enemy_from_difficulty_tier()
		enemy_to_spawn_next()
		enemies_spawned += 1
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))

func _spawn_platform():
	platform_to_spawn_next()
	platform_spawn_timer.set_wait_time(seconds_platform_spawn_frequency + rng.randf_range(0.1, 1.0))

func _spawn_unique_while_alive_enemy():
	if current_difficulty_tier > 1 && unique_enemy_list.size() > 0 && check_for_unique_enemies() <= 0:
		var parent_node = self.get_parent()
		if parent_node != null:
			unique_enemy_to_spawn = unique_enemy_list[rng.randi() % unique_enemy_list.size()]
			var _unique_enemy_to_spawn = unique_enemy_to_spawn.instance()
			if !_unique_enemy_to_spawn.is_in_group("non_boss_enemy"):
				_unique_enemy_to_spawn.add_to_group("non_boss_enemy")
			if _unique_enemy_to_spawn.initial_scroll_speed == 0:
				_unique_enemy_to_spawn.initial_scroll_speed = default_scroll_speed
			if spawn_points.size() > 0:
				var spawn_place = spawn_at_valid_height(_unique_enemy_to_spawn)
				_unique_enemy_to_spawn.position = spawn_place
				parent_node.add_child(_unique_enemy_to_spawn)

func platform_to_spawn_next():
	if platform_list.size() == 0:
		print("no platforms found!")
	else:
		platform_to_spawn = platform_list[rng.randi() % platform_list.size()]
		spawn_platform_to_scene()

func enemy_to_spawn_next():
	if current_enemy_list.size() == 0:
		print("no enemies found!")
	else:
		enemy_to_spawn = current_enemy_list[rng.randi() % current_enemy_list.size()]
		spawn_enemy_to_scene()

func spawn_at_valid_height(_enemy_to_spawn) -> Vector2:
	var spawn_height = _enemy_to_spawn.spawn_height
	match spawn_height:
		DataClasses.SpawnHeight.ANY:
			var all_points = spawn_points.values()
			return all_points[rng.randi_range(0, all_points.size() - 1)]
		DataClasses.SpawnHeight.HIGH_ONLY:
			return spawn_points[DataClasses.SpawnHeight.HIGH_ONLY]
		DataClasses.SpawnHeight.MED_ONLY:
			return spawn_points[DataClasses.SpawnHeight.MED_ONLY]
		DataClasses.SpawnHeight.LOW_ONLY:
			return spawn_points[DataClasses.SpawnHeight.LOW_ONLY]
		DataClasses.SpawnHeight.HIGH_MED:
			var valid_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.MED_ONLY)]
			return valid_points[rng.randi_range(0, valid_points.size() - 1)]
		DataClasses.SpawnHeight.MED_LOW:
			var valid_points = [spawn_points.get(DataClasses.SpawnHeight.MED_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]
			return valid_points[rng.randi_range(0, valid_points.size() - 1)]
		DataClasses.SpawnHeight.HIGH_LOW:
			var valid_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]
			return valid_points[rng.randi_range(0, valid_points.size() - 1)]
		DataClasses.SpawnHeight.GROUND_ONLY:		
			if _enemy_to_spawn.custom_grounded_spawn_point != null:
				return _enemy_to_spawn.custom_grounded_spawn_point
			else:
				print_debug("Couldnt find point for grounded enemy, estimating height to spawn")
				return Vector2(2006, 951)
		_:
			var all_points = spawn_points.values()
			return all_points[rng.randi_range(0, all_points.size() - 1)]

func spawn_enemy_to_scene():
	var parent_node = self.get_parent()
	if parent_node != null:
		var _enemy_to_spawn = enemy_to_spawn.instance()
		if !_enemy_to_spawn.is_in_group("non_boss_enemy"):
			_enemy_to_spawn.add_to_group("non_boss_enemy")
		if _enemy_to_spawn.initial_scroll_speed == 0:
			_enemy_to_spawn.initial_scroll_speed = default_scroll_speed
		if spawn_points.size() > 0:
			var spawn_place = spawn_at_valid_height(_enemy_to_spawn)
			_enemy_to_spawn.position = spawn_place
			parent_node.add_child(_enemy_to_spawn)
		else:
			print("No spawn points found!")

func spawn_platform_to_scene():
	var parent_node = self.get_parent()
	if parent_node != null && platform_to_spawn != null:
		var _platform_to_spawn = platform_to_spawn.instance()
		if !_platform_to_spawn.is_in_group("spawned_platform"):
			_platform_to_spawn.add_to_group("spawned_platform")
		if _platform_to_spawn.scroll_speed == 0:
			_platform_to_spawn.scroll_speed = default_scroll_speed
		_platform_to_spawn.position = default_platform_spawn_position
		parent_node.add_child(_platform_to_spawn)


func _direct_spawn_obstacle_at_position(obstacle: PackedScene, position: Vector2, scroll_speed):
	var parent_node = self.get_parent()
	var _obstacle_to_spawn = obstacle.instance()
	if scroll_speed != null:
		_obstacle_to_spawn.scroll_speed = default_scroll_speed
	else:
		_obstacle_to_spawn.scroll_speed = scroll_speed
	_obstacle_to_spawn.position = position
	parent_node.add_child(_obstacle_to_spawn)

func _direct_spawn_dog(dog: PackedScene, dogType: String, position: Vector2, speed, disabled_float):
	var parent_node = self.get_parent()
	var _dog = dog.instance()
	if speed != null:
		_dog.scroll_speed = speed
	else:
		_dog.scroll_speed = default_scroll_speed
	_dog.set_dogu(dogType)
	_dog.disable_float(disabled_float)
	_dog.position = position
	#parent_node.add_child(_dog)
	parent_node.call_deferred("add_child", _dog)

func spawn_instanced_background_element(element,  background_element_name: String, position: Vector2, scroll_speed):
	var parent_node = self.get_parent()
	if parent_node != null:
		element.position = position
		if "initial_speed" in element:
			element.initial_speed = scroll_speed
		if "scroll_speed" in element:
			element.scroll_speed = scroll_speed
		level_background.get_node_or_null(background_element_name).add_child(element)	


func spawn_to_background_element(element: PackedScene, background_element_name: String, position: Vector2, scroll_speed):
	var parent_node = self.get_parent()
	if parent_node != null:
		var _element_to_spawn = element.instance()
		_element_to_spawn.position = position
		if "initial_speed" in _element_to_spawn:
			_element_to_spawn.initial_speed = scroll_speed
		if "scroll_speed" in _element_to_spawn:
			_element_to_spawn.scroll_speed = scroll_speed
		level_background.get_node_or_null(background_element_name).add_child(_element_to_spawn)

func _direct_spawn_at_position(enemy: PackedScene, position: Vector2, speed):
	var _direct_enemy_to_spawn = enemy.instance()
	if !_direct_enemy_to_spawn.is_in_group("non_boss_enemy"):
		_direct_enemy_to_spawn.add_to_group("non_boss_enemy")
	if speed != null:
		_direct_enemy_to_spawn.initial_scroll_speed = speed
	else:
		_direct_enemy_to_spawn.initial_scroll_speed = default_scroll_speed
	_direct_enemy_to_spawn.position = position
	self.get_parent().call_deferred("add_child", _direct_enemy_to_spawn)

func kill_non_boss_enemies():
	var non_boss_enemies = get_tree().get_nodes_in_group("non_boss_enemy")
	for enemy in non_boss_enemies:
		if enemy.has_method("call_death") and is_instance_valid(enemy):
			enemy.call_death(false)

func _direct_instanced_boss_at_position(boss: PackedScene, position: Vector2, speed):
	var parent_node = self.get_parent()
	if parent_node != null && boss != null:
		boss.add_to_group("boss_enemy")
		boss.global_position = position
		parent_node.add_child(boss)
		Events.emit_signal("boss_spawned")

func _direct_spawn_boss_at_position(boss: PackedScene, position: Vector2, speed):
	var parent_node = self.get_parent()
	if parent_node != null && boss != null:
		var _boss_to_spawn = boss.instance()
		_boss_to_spawn.add_to_group("boss_enemy")
		_boss_to_spawn.global_position = position
		parent_node.add_child(_boss_to_spawn)
		Events.emit_signal("boss_spawned")


func increment_difficulty_tier():
	current_difficulty_tier = current_difficulty_tier + 1

func add_enemy_to_spawn_list(enemy_to_add : PackedScene, tier : int):
	if tier <= 1:
		first_tier_enemy_list.append(enemy_to_add)
	elif tier <= 2:
		second_tier_enemy_list.append(enemy_to_add)
	elif tier >= 3:
		third_tier_enemy_list.append(enemy_to_add)

func check_for_unique_enemies():
	var unique_while_alive_enemy = get_tree().get_nodes_in_group("unique_while_alive")
	return unique_while_alive_enemy.size()
