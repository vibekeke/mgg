extends Node2D

export (int) var max_enemies_on_screen = 5
export (float) var seconds_enemy_spawn_frequency = 1.0
export (float) var seconds_spawn_unique_while_alive_frequency = 2.0
onready var current_enemy_list : Array = []
export (Array, PackedScene) var first_tier_enemy_list
export (Array, PackedScene) var second_tier_enemy_list
export (Array, PackedScene) var third_tier_enemy_list
export (Array, PackedScene) var unique_enemy_list
export (int) var default_scroll_speed = 500

onready var spawn_timer : Timer = Timer.new()
onready var spawn_unique_while_alive_timer : Timer = Timer.new()
onready var enemies_spawned : int = 0
onready var current_difficulty_tier : int = 1
onready var cached_tier_1_enemies : Array = []
onready var cached_tier_2_enemies : Array = []
onready var cached_tier_3_enemies : Array = []
onready var cached_arrays_built : bool = false
onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
onready var spawn_paths = get_node("%SpawnPaths")
onready var level_background = get_node_or_null("%LevelBackground")
onready var level_events_manager = get_node("%LevelEventsManager")
onready var cached_parent_node = null
onready var cached_high_med_points : Array = []
onready var cached_med_low_points : Array = []
onready var cached_high_low_points : Array = []

var enemy_to_spawn = null
var unique_enemy_to_spawn = null
var spawn_points = {}

# Enemy pooling system
var tier1_enemy_pool: Array = []
var tier2_enemy_pool: Array = []
var tier3_enemy_pool: Array = []
var unique_enemy_pool: Array = []
var pool_size_per_tier: int = 10

func _ready():
	rng.randomize()
	build_cached_arrays()
	cached_parent_node = self.get_parent()
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	Events.connect("enemy_despawned", self, "_on_regular_enemy_death")
	Events.connect("enemy_return_to_pool", self, "_on_enemy_return_to_pool")
	if spawn_paths != null:
		_on_level_spawn_points(spawn_paths.get_spawn_points())
	spawn_timer.set_name("spawn_timer")
	spawn_timer.connect("timeout", self, "_spawn_enemy")
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))
	self.add_child(spawn_timer)
	spawn_timer.start()

	
	spawn_unique_while_alive_timer.set_name("spawn_unique_while_alive_timer")
	spawn_unique_while_alive_timer.connect("timeout", self, "_spawn_unique_while_alive_enemy")
	spawn_unique_while_alive_timer.set_wait_time(seconds_spawn_unique_while_alive_frequency + rng.randf_range(1.0, 3.5))
	self.add_child(spawn_unique_while_alive_timer)
	spawn_unique_while_alive_timer.start()
	
	_preload_enemy_pools()

func build_cached_arrays():
	if !cached_arrays_built:
		cached_tier_1_enemies = first_tier_enemy_list
		cached_tier_2_enemies = first_tier_enemy_list + second_tier_enemy_list
		cached_tier_3_enemies = first_tier_enemy_list + second_tier_enemy_list + third_tier_enemy_list
		cached_arrays_built = true

func get_enemy_from_difficulty_tier():
	if current_difficulty_tier <= 1:
		current_enemy_list = cached_tier_1_enemies
	elif current_difficulty_tier <= 2:
		current_enemy_list = cached_tier_2_enemies
	elif current_difficulty_tier >= 3:
		current_enemy_list = cached_tier_3_enemies

func enemy_spawner_is_running() -> bool:
	return !(spawn_timer.is_stopped() && spawn_unique_while_alive_timer.is_stopped())

func stop_enemy_spawner():
	spawn_timer.stop()
	spawn_unique_while_alive_timer.stop()
	
func start_enemy_spawner():
	spawn_timer.start()
	spawn_unique_while_alive_timer.start()
	

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
	cached_high_med_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.MED_ONLY)]
	cached_med_low_points = [spawn_points.get(DataClasses.SpawnHeight.MED_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]
	cached_high_low_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]

func _on_regular_enemy_death():
	enemies_spawned -= 1
	
func _spawn_enemy():
	if enemies_spawned < max_enemies_on_screen:
		get_enemy_from_difficulty_tier()
		enemy_to_spawn_next()
		enemies_spawned += 1
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))


func _spawn_unique_while_alive_enemy():
	if current_difficulty_tier > 1 && unique_enemy_list.size() > 0 && check_for_unique_enemies() <= 0:
		if cached_parent_node != null:
			var _unique_enemy_to_spawn = _get_pooled_unique_enemy()
			if _unique_enemy_to_spawn != null:
				if spawn_points.size() > 0:
					var spawn_place = spawn_at_valid_height(_unique_enemy_to_spawn)
					_unique_enemy_to_spawn.position = spawn_place
					cached_parent_node.add_child(_unique_enemy_to_spawn)


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
			return cached_high_med_points[rng.randi_range(0, cached_high_med_points.size() - 1)]
		DataClasses.SpawnHeight.MED_LOW:
			return cached_med_low_points[rng.randi_range(0, cached_med_low_points.size() - 1)]
		DataClasses.SpawnHeight.HIGH_LOW:
			return cached_high_low_points[rng.randi_range(0, cached_high_low_points.size() - 1)]
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
	if cached_parent_node != null:
		var _enemy_to_spawn = _get_pooled_enemy(current_difficulty_tier)
		if _enemy_to_spawn != null:
			if spawn_points.size() > 0:
				var spawn_place = spawn_at_valid_height(_enemy_to_spawn)
				_enemy_to_spawn.position = spawn_place
				cached_parent_node.add_child(_enemy_to_spawn)
			else:
				print("No spawn points found!")
		else:
			print("Failed to get pooled enemy!")


func _direct_spawn_dog(dog: PackedScene, dogType: String, position: Vector2, speed, disabled_float):
	var _dog = dog.instance()
	if speed != null:
		_dog.scroll_speed = speed
	else:
		_dog.scroll_speed = default_scroll_speed
	_dog.set_dogu(dogType)
	_dog.disable_float(disabled_float)
	_dog.position = position
	cached_parent_node.call_deferred("add_child", _dog)

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
	cached_arrays_built = false

func check_for_unique_enemies():
	var unique_while_alive_enemy = get_tree().get_nodes_in_group("unique_while_alive")
	return unique_while_alive_enemy.size()

# Enemy pooling system functions
func _preload_enemy_pools():
	print("EnemySpawner: Preloading enemy pools...")
	
	# Preload tier 1 enemies
	if first_tier_enemy_list.size() > 0:
		for i in range(pool_size_per_tier):
			var enemy_scene = first_tier_enemy_list[rng.randi() % first_tier_enemy_list.size()]
			var enemy_instance = enemy_scene.instance()
			_prepare_pooled_enemy(enemy_instance)
			tier1_enemy_pool.append(enemy_instance)
	
	# Preload tier 2 enemies (if available)
	if second_tier_enemy_list.size() > 0:
		for i in range(pool_size_per_tier):
			var enemy_scene = second_tier_enemy_list[rng.randi() % second_tier_enemy_list.size()]
			var enemy_instance = enemy_scene.instance()
			_prepare_pooled_enemy(enemy_instance)
			tier2_enemy_pool.append(enemy_instance)
	
	# Preload tier 3 enemies (if available)
	if third_tier_enemy_list.size() > 0:
		for i in range(pool_size_per_tier):
			var enemy_scene = third_tier_enemy_list[rng.randi() % third_tier_enemy_list.size()]
			var enemy_instance = enemy_scene.instance()
			_prepare_pooled_enemy(enemy_instance)
			tier3_enemy_pool.append(enemy_instance)
	
	# Preload unique enemies (if available)
	if unique_enemy_list.size() > 0:
		for i in range(pool_size_per_tier / 2):  # Fewer unique enemies
			var enemy_scene = unique_enemy_list[rng.randi() % unique_enemy_list.size()]
			var enemy_instance = enemy_scene.instance()
			_prepare_pooled_enemy(enemy_instance)
			enemy_instance.add_to_group("unique_while_alive")
			unique_enemy_pool.append(enemy_instance)
	
	print("EnemySpawner: Preloading complete - ", 
		  tier1_enemy_pool.size(), " tier1, ",
		  tier2_enemy_pool.size(), " tier2, ",
		  tier3_enemy_pool.size(), " tier3, ",
		  unique_enemy_pool.size(), " unique enemies")

func _prepare_pooled_enemy(enemy_instance: Node):
	enemy_instance.add_to_group("non_boss_enemy")
	if enemy_instance.initial_scroll_speed == 0:
		enemy_instance.initial_scroll_speed = default_scroll_speed
	enemy_instance.visible = false
	enemy_instance.set_process(false)

func _get_pooled_enemy(tier: int) -> Node:
	var pool: Array
	var fallback_list: Array
	
	match tier:
		1:
			pool = tier1_enemy_pool
			fallback_list = first_tier_enemy_list
		2:
			pool = tier2_enemy_pool
			fallback_list = second_tier_enemy_list
		3:
			pool = tier3_enemy_pool
			fallback_list = third_tier_enemy_list
		_:
			pool = tier1_enemy_pool
			fallback_list = first_tier_enemy_list
	
	if pool.size() > 0:
		var enemy = pool.pop_back()
		enemy.visible = true
		enemy.set_process(true)
		return enemy
	else:
		return _create_new_enemy_from_list(fallback_list)

func _get_pooled_unique_enemy() -> Node:
	if unique_enemy_pool.size() > 0:
		var enemy = unique_enemy_pool.pop_back()
		enemy.visible = true
		enemy.set_process(true)
		return enemy
	else:
		return _create_new_unique_enemy()

func _create_new_enemy_from_list(enemy_list: Array) -> Node:
	if enemy_list.size() > 0:
		var enemy_scene = enemy_list[rng.randi() % enemy_list.size()]
		var enemy_instance = enemy_scene.instance()
		_prepare_pooled_enemy(enemy_instance)
		enemy_instance.visible = true
		enemy_instance.set_process(true)
		return enemy_instance
	return null

func _create_new_unique_enemy() -> Node:
	if unique_enemy_list.size() > 0:
		var enemy_scene = unique_enemy_list[rng.randi() % unique_enemy_list.size()]
		var enemy_instance = enemy_scene.instance()
		_prepare_pooled_enemy(enemy_instance)
		enemy_instance.add_to_group("unique_while_alive")
		enemy_instance.visible = true
		enemy_instance.set_process(true)
		return enemy_instance
	return null

func _return_enemy_to_pool(enemy: Node):
	if enemy == null or !is_instance_valid(enemy):
		return
	
	# Determine which pool this enemy belongs to
	var enemy_scene_path = enemy.filename
	var pool: Array
	var max_pool_size = pool_size_per_tier
	
	# Check if it's a unique enemy
	if enemy.is_in_group("unique_while_alive"):
		pool = unique_enemy_pool
		max_pool_size = pool_size_per_tier / 2
	else:
		# Determine tier based on enemy type
		for scene in first_tier_enemy_list:
			if scene.resource_path == enemy_scene_path:
				pool = tier1_enemy_pool
				break
		
		if pool.size() == 0:  # Not found in tier 1
			for scene in second_tier_enemy_list:
				if scene.resource_path == enemy_scene_path:
					pool = tier2_enemy_pool
					break
		
		if pool.size() == 0:  # Not found in tier 1 or 2
			for scene in third_tier_enemy_list:
				if scene.resource_path == enemy_scene_path:
					pool = tier3_enemy_pool
					break
		
		if pool.size() == 0:  # Default to tier 1 if not found
			pool = tier1_enemy_pool
	
	# Return to pool if there's space, otherwise destroy
	if pool.size() < max_pool_size:
		if enemy.get_parent() != null:
			enemy.get_parent().remove_child(enemy)
		enemy.visible = false
		enemy.set_process(false)
		# Reset enemy state if it has a reset method
		if enemy.has_method("reset_for_pool"):
			enemy.reset_for_pool()
		pool.append(enemy)
	else:
		enemy.queue_free()

func _on_enemy_return_to_pool(enemy: Node):
	_return_enemy_to_pool(enemy)
