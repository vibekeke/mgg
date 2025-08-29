extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var platform_spawn_point : Position2D = get_node("%PlatformSpawnPoint")
onready var start_event_timer = Timer.new()
onready var spawn_enemies_timer = Timer.new()
onready var spawn_platforms_timer = Timer.new()
onready var spawn_background_enemies_timer = Timer.new()
onready var wait_after_stopping_spawner_timer = Timer.new()
export var time_until_event_start = 10.0
var num_background_enemies_spawned = 0
var num_enemies_spawned = 0
var num_platforms_spawned = 0
var enemy_spawn_start = false
var background_enemy_spawn_start = false

var enemy_spawn_place = Vector2(2200, 799)
var background_enemy_spawn_place = Vector2(0, 861)
var enemy_speed = 1500
var platform_scroll_speed = 500

export var enemy_to_spawn : PackedScene
export var background_element_to_spawn : PackedScene
export var platform_to_spawn : PackedScene

var preloaded_platforms = []
var preloaded_background_enemies = []
var preloaded_enemies = []

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 2
	event_name = "Level1_Event2"
	
	_preload_all_objects()

func _preload_all_objects():
	print("Level1_Event2: Preloading objects...")
	
	for i in range(3):
		var platform = platform_to_spawn.instance()
		platform.scroll_speed = platform_scroll_speed
		platform.visible = false
		platform.set_process(false)
		preloaded_platforms.append(platform)
	
	for i in range(20):
		var bg_enemy = background_element_to_spawn.instance()
		bg_enemy.scroll_speed = enemy_speed
		bg_enemy.visible = false
		bg_enemy.set_process(false)
		preloaded_background_enemies.append(bg_enemy)
	
	for i in range(20):
		var enemy = enemy_to_spawn.instance()
		enemy.initial_scroll_speed = enemy_speed
		enemy.visible = false
		enemy.set_process(false)
		preloaded_enemies.append(enemy)
	
	print("Level1_Event2: Preloading complete - ", preloaded_platforms.size(), " platforms, ", 
		  preloaded_background_enemies.size(), " bg enemies, ", preloaded_enemies.size(), " enemies")

func _spawn_preloaded_platform():
	if preloaded_platforms.size() > 0:
		var platform = preloaded_platforms.pop_front()
		platform.position = platform_spawn_point.global_position
		platform.visible = true
		platform.set_process(true)
		platform_spawner.cached_parent_node.add_child(platform)
		print("Level1_Event2: Spawned preloaded platform at ", platform.position)
	else:
		print("Level1_Event2: No more preloaded platforms available!")

func _spawn_preloaded_background_enemy():
	if preloaded_background_enemies.size() > 0:
		var bg_enemy = preloaded_background_enemies.pop_front()
		bg_enemy.position = background_enemy_spawn_place
		if "initial_speed" in bg_enemy:
			bg_enemy.initial_speed = enemy_speed
		if "scroll_speed" in bg_enemy:
			bg_enemy.scroll_speed = enemy_speed
		bg_enemy.visible = true
		bg_enemy.set_process(true)
		enemy_spawner.level_background.get_node_or_null('BackForestBackground').add_child(bg_enemy)
		print("Level1_Event2: Spawned preloaded background enemy")
	else:
		print("Level1_Event2: No more preloaded background enemies available!")

func _spawn_preloaded_enemy():
	if preloaded_enemies.size() > 0:
		var enemy = preloaded_enemies.pop_front()
		if !enemy.is_in_group("non_boss_enemy"):
			enemy.add_to_group("non_boss_enemy")
		enemy.position = enemy_spawn_place
		enemy.visible = true
		enemy.set_process(true)
		enemy_spawner.get_parent().call_deferred("add_child", enemy)
		print("Level1_Event2: Spawned preloaded enemy at ", enemy.position)
	else:
		print("Level1_Event2: No more preloaded enemies available!")

func _on_level_event_complete(level_event_name, level_event_number):
	if level_event_number == 1:
		
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)
		
		wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.set_wait_time(1.5)
		wait_after_stopping_spawner_timer.set_one_shot(false)

		spawn_enemies_timer.set_name(event_name + "_spawn_enemies_timer")
		spawn_enemies_timer.connect("timeout", self, "_on_spawn_enemies_timer")
		spawn_enemies_timer.set_one_shot(false)
		spawn_enemies_timer.set_wait_time(0.1)
		
		spawn_background_enemies_timer.set_name(event_name + "_spawn_background_enemies_timer")
		spawn_background_enemies_timer.connect("timeout", self, "_on_spawn_background_enemies_timer")
		spawn_background_enemies_timer.set_one_shot(false)
		spawn_background_enemies_timer.set_wait_time(0.1)

		spawn_platforms_timer.set_name(event_name + "_spawn_platforms_timer")
		spawn_platforms_timer.connect("timeout", self, "_on_spawn_platforms_timer")
		spawn_platforms_timer.set_one_shot(false)
		spawn_platforms_timer.set_wait_time(3.0)
		
		self.add_child(start_event_timer)
		self.add_child(wait_after_stopping_spawner_timer)
		self.add_child(spawn_enemies_timer)
		self.add_child(spawn_platforms_timer)
		self.add_child(spawn_background_enemies_timer)
		
		start_event_timer.start()

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null and platform_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		platform_spawner.stop_platform_spawner()
		wait_after_stopping_spawner_timer.start()
	else:
		printerr("One of the spawners was not detected. Something has gone wrong here")

func _on_spawn_platforms_timer() -> void:
	_spawn_preloaded_platform()
	if !background_enemy_spawn_start:
		background_enemy_spawn_start = true
		spawn_background_enemies_timer.start()
	num_platforms_spawned += 1
	if num_platforms_spawned >= 3 and !enemy_spawn_start:
		enemy_spawn_start = true
		spawn_enemies_timer.start()

func _on_spawn_background_enemies_timer() -> void:
	_spawn_preloaded_background_enemy()
	num_background_enemies_spawned += 1
	if num_background_enemies_spawned >= 20:
		spawn_background_enemies_timer.stop()

func _on_spawn_enemies_timer() -> void:
	_spawn_preloaded_enemy()
	num_enemies_spawned += 1
	if num_enemies_spawned >= 20:
		spawn_enemies_timer.stop()
		spawn_platforms_timer.stop()
		end_event()

func event_start() -> void:
	if enemy_spawner != null:
		spawn_platforms_timer.start()
	else:
		print("enemy spawner is null")
		
func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.start_enemy_spawner()
	platform_spawner.start_platform_spawner()
	enemy_spawner.increment_difficulty_tier()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
