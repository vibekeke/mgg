extends Node

@export var regular_enemies # (Array, PackedScene)
@export var level_scene_path : NodePath
@onready var level_main_scene = get_node(level_scene_path)

@export var spawn_points_path : NodePath

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var spawn_paths_node = get_node(spawn_points_path)
@onready var spawn_points = spawn_paths_node.get_spawn_points()

@onready var high_med_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.MED_ONLY)]
@onready var med_points = [spawn_points.get(DataClasses.SpawnHeight.MED_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]
@onready var high_low_points = [spawn_points.get(DataClasses.SpawnHeight.HIGH_ONLY), spawn_points.get(DataClasses.SpawnHeight.LOW_ONLY)]

@onready var spawn_frequency_timer : Timer = get_node("%SpawnFrequencyTimer")

@onready var enemy_pools : Dictionary = {}
@onready var active_enemies : Array = []

@export var enemy_pool_size : int = 50
@export var max_active_enemes : int = 4

@export var enemy_spawn_frequency : float = 0.1
@export var enemy_spawn_variance : float = 0.05

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
			return high_med_points[rng.randi_range(0, high_med_points.size() - 1)]
		DataClasses.SpawnHeight.MED_LOW:
			return med_points[rng.randi_range(0, med_points.size() - 1)]
		DataClasses.SpawnHeight.HIGH_LOW:
			return high_low_points[rng.randi_range(0, high_low_points.size() - 1)]
		DataClasses.SpawnHeight.GROUND_ONLY:
			if _enemy_to_spawn.custom_grounded_spawn_point != null:
				return _enemy_to_spawn.custom_grounded_spawn_point
			else:
				print_debug("Couldnt find point for grounded enemy, estimating height to spawn")
				return Vector2(2006, 951)
		_:
			var all_points = spawn_points.values()
			return all_points[rng.randi_range(0, all_points.size() - 1)]

func _ready():
	rng.randomize()
	_initialize_enemy_pools()
	start_spawner()

func start_spawner():
	spawn_frequency_timer.start()
	
func stop_spawner():
	spawn_frequency_timer.stop()

func _initialize_enemy_pools():
	for enemy_scene in regular_enemies:
		var pool = []
		for i in range(enemy_pool_size):
			var enemy = enemy_scene.instantiate()
			enemy.visible = false
			enemy.set_physics_process(false)
			
			var can_take_damage_component = enemy.get_node_or_null("CanTakeDamage")
			if can_take_damage_component:
				can_take_damage_component.connect("enemy_return_to_pool", Callable(self, "_return_to_enemy_pool"))
			
			level_main_scene.call_deferred("add_child", enemy)
			pool.append(enemy)
		
		enemy_pools[enemy_scene] = pool

func spawn_available_enemy():
	if active_enemies.size() >= max_active_enemes:
		return
		
	if regular_enemies.size() > 0:
		var enemy_scene = regular_enemies[rng.randi() % regular_enemies.size()]
		var pool = enemy_pools.get(enemy_scene, [])
		
		if pool.size() > 0:
			var enemy = pool.pop_back()
			active_enemies.append(enemy)
			activate_enemy(enemy)

func activate_enemy(enemy):
	var spawn_pos = spawn_at_valid_height(enemy)
	enemy.position = spawn_pos
	enemy.visible = true
	enemy.set_physics_process(true)

	# Re-enable collision detection
	if enemy.area2d:
		enemy.area2d.monitoring = true
		enemy.area2d.monitorable = true

	var can_take_damage = enemy.get_node_or_null("CanTakeDamage")
	if can_take_damage:
		can_take_damage.death_called = false
		can_take_damage.damage_disabled = false

func _return_to_enemy_pool(dead_enemy):
	if dead_enemy in active_enemies:
		active_enemies.erase(dead_enemy)
	
	dead_enemy.reset_for_pool()

	if enemy_pools.size() > 0:
		var first_pool = enemy_pools.values()[0]
		first_pool.append(dead_enemy)


func _on_SpawnFrequencyTimer_timeout():
	spawn_available_enemy()
	spawn_frequency_timer.set_wait_time(enemy_spawn_frequency + rng.randf_range(0, enemy_spawn_variance))
