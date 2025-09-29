extends Node

@export var max_platforms_on_screen: int = 3
@export var seconds_platform_spawn_frequency: float = 2.0
@export var default_platform_spawn_position: Vector2 = Vector2(2000, 410)
@export var platform_list: Array[PackedScene]
@export var default_scroll_speed: int = 500
@export var platform_spawn_point_path: NodePath
var platform_spawn_point = null

@onready var platform_spawn_timer : Timer = Timer.new()
@onready var platforms_spawned : int = 0
@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var cached_parent_node = null

var platform_to_spawn = null
var platform_pool : Array = []
var pool_size : int = 5

func _ready():
	platform_spawn_point = get_node_or_null(platform_spawn_point_path)
	if platform_spawn_point == null:
		printerr("No platform spawn point detected!")
	rng.randomize()
	cached_parent_node = self.get_parent()
	
	platform_spawn_timer.set_name("platform_spawn_timer")
	platform_spawn_timer.connect("timeout", Callable(self, "_spawn_platform"))
	platform_spawn_timer.set_wait_time(seconds_platform_spawn_frequency + rng.randf_range(0.1, 1.0))
	self.add_child(platform_spawn_timer)
	platform_spawn_timer.start()
	
	Events.connect("platform_despawned", Callable(self, "_on_platform_despawned"))
	Events.connect("platform_return_to_pool", Callable(self, "_on_platform_return_to_pool"))
	Events.connect("enemy_spawner_enabled", Callable(self, "_on_enemy_spawner_enabled"))
	
	_preload_platform_pool()

func _preload_platform_pool():
	if platform_list.size() > 0:
		for i in range(pool_size):
			var platform_scene = platform_list[rng.randi() % platform_list.size()]
			var platform_instance = platform_scene.instantiate()
			platform_instance.add_to_group("spawned_platform")
			if platform_instance.scroll_speed == 0:
				platform_instance.scroll_speed = default_scroll_speed
			platform_instance.visible = false
			platform_instance.set_process(false)
			platform_pool.append(platform_instance)

func _get_pooled_platform() -> Node:
	if platform_pool.size() > 0:
		var platform = platform_pool.pop_back()
		platform.visible = true
		platform.set_process(true)
		return platform
	else:
		return _create_new_platform()

func _create_new_platform() -> Node:
	if platform_list.size() > 0:
		platform_to_spawn = platform_list[rng.randi() % platform_list.size()]
		var platform_instance = platform_to_spawn.instance()
		platform_instance.add_to_group("spawned_platform")
		if platform_instance.scroll_speed == 0:
			platform_instance.scroll_speed = default_scroll_speed
		return platform_instance
	return null

func _return_to_pool(platform: Node):
	if platform_pool.size() < pool_size:
		# Remove from parent first
		if platform.get_parent() != null:
			platform.get_parent().call_deferred("remove_child", platform)
		platform.visible = false
		platform.set_process(false)
		platform.position = platform_spawn_point.global_position
		platform_pool.append(platform)
	else:
		platform.queue_free()

func _on_platform_despawned():
	if platforms_spawned > 0:
		platforms_spawned -= 1

func _on_platform_return_to_pool(platform: Node):
	if platform != null and is_instance_valid(platform):
		_return_to_pool(platform)
		if platforms_spawned > 0:
			platforms_spawned -= 1

func _on_enemy_spawner_enabled(enabled: bool):
	if enabled:
		start_platform_spawner()
	else:
		stop_platform_spawner()

func _spawn_platform():
	if platforms_spawned < max_platforms_on_screen:
		_spawn_platform_to_scene()
		platforms_spawned += 1
	platform_spawn_timer.set_wait_time(seconds_platform_spawn_frequency + rng.randf_range(0.1, 1.0))

func _spawn_platform_to_scene():
	if cached_parent_node != null:
		var platform = _get_pooled_platform()
		if platform != null:
			platform.position = platform_spawn_point.global_position
			cached_parent_node.add_child(platform)

func platform_spawner_is_running() -> bool:
	return !platform_spawn_timer.is_stopped()

func stop_platform_spawner():
	platform_spawn_timer.stop()

func start_platform_spawner():
	platform_spawn_timer.start()

func set_spawn_frequency(frequency: float):
	seconds_platform_spawn_frequency = frequency
	if platform_spawn_timer:
		platform_spawn_timer.set_wait_time(frequency + rng.randf_range(0.1, 1.0))

func clear_platform_pool():
	for platform in platform_pool:
		if is_instance_valid(platform):
			platform.queue_free()
	platform_pool.clear()

func _direct_spawn_obstacle_at_position(obstacle: PackedScene, position: Vector2, scroll_speed):
	var _obstacle_to_spawn = obstacle.instantiate()
	if scroll_speed != null:
		_obstacle_to_spawn.scroll_speed = scroll_speed
	else:
		_obstacle_to_spawn.scroll_speed = default_scroll_speed
	_obstacle_to_spawn.position = position
	cached_parent_node.add_child(_obstacle_to_spawn)
