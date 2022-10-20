extends Node2D

export (int) var max_enemies_on_screen = 5
export (float) var seconds_enemy_spawn_frequency = 1.0
export (float) var seconds_until_boss = 60.0
export (Array, PackedScene) var enemy_list
export (int) var default_scroll_speed = 500
export (PackedScene) var boss

onready var spawn_timer = Timer.new()
onready var until_boss_timer = Timer.new()
onready var enemies_spawned = 0
onready var rng = RandomNumberGenerator.new()
onready var spawn_paths = get_node("%SpawnPaths")
var enemy_to_spawn = null
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
	
	until_boss_timer.set_name("until_boss_timer")
	until_boss_timer.connect("timeout", self, "_spawn_boss")
	until_boss_timer.set_wait_time(seconds_until_boss)
	self.add_child(until_boss_timer)
	until_boss_timer.start()

func _spawn_grouped_enemy():
	pass

func stop_enemy_spawner():
	spawn_timer.stop()
	
func start_enemy_spawner():
	spawn_timer.start()

func _on_level_spawn_points(_spawn_points):
	spawn_points = _spawn_points

func _on_regular_enemy_death():
	enemies_spawned -= 1
	
func _spawn_enemy():
	rng.randomize()
	if enemies_spawned < max_enemies_on_screen:
		enemy_to_spawn_next()
		enemies_spawned += 1
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))

func _spawn_boss():
	spawn_boss_to_scene()
	until_boss_timer.stop()
	spawn_timer.stop()
	kill_non_boss_enemies()

func enemy_to_spawn_next():
	if enemy_list.size() == 0:
		print("no enemies found!")
	else:
		rng.randomize()
		enemy_to_spawn = enemy_list[randi() % enemy_list.size()]
		spawn_enemy_to_scene()

func spawn_at_valid_height(_enemy_to_spawn):
	rng.randomize()
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
		_:
			var all_points = spawn_points.values()
			return all_points[rng.randi_range(0, all_points.size() - 1)]

func spawn_enemy_to_scene():
	var parent_node = self.get_parent()
	if parent_node != null:
		var _enemy_to_spawn = enemy_to_spawn.instance()
		if !_enemy_to_spawn.is_in_group("non_boss_enemy"):
			_enemy_to_spawn.add_to_group("non_boss_enemy")
		_enemy_to_spawn.initial_scroll_speed = default_scroll_speed
		rng.randomize()
		if spawn_points.size() > 0:
			print("spawning enemy at ", _enemy_to_spawn.spawn_height)
			var spawn_place = spawn_at_valid_height(_enemy_to_spawn)
			_enemy_to_spawn.position = spawn_place
			parent_node.add_child(_enemy_to_spawn)
		else:
			print("No spawn points found!")

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

func spawn_boss_to_scene():
	var parent_node = self.get_parent()
	if parent_node != null && boss!= null:
		var _boss_to_spawn = boss.instance()
		var spawn_position = spawn_points[DataClasses.SpawnHeight.MED_ONLY]
		_boss_to_spawn.position = spawn_position
		_boss_to_spawn.add_to_group("boss_enemy")
		_boss_to_spawn.global_position = Vector2(1510, 620)
		parent_node.add_child(_boss_to_spawn)
		Events.emit_signal("boss_spawned")
	else:
		if parent_node == null:
			print_debug("No parent node found in enemy spawner.")
		if boss == null:
			print_debug("No boss node found in enemy spawner.")
