extends LevelEvent

onready var event_timer = Timer.new()
onready var enemy_spawner = get_node("%EnemySpawner")
var start_event_timer = Timer.new()
var spawn_enemies_timer = Timer.new()
var spawn_platforms_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()
var num_enemies_spawned = 0
var num_platforms_spawned = 0
var enemy_spawn_start = false
var platform_spawn_place = Vector2(2200, 420)

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 2
	event_name = 'Level1_Event2'

func setup_and_attach_timer(timer_name: String, one_shot: bool, timeout_function: String, wait_time: int):
	var timer = Timer.new()
	timer.set_name(timer)
	timer.connect("timeout", self, timeout_function)
	timer.set_wait_time(wait_time)

func _on_level_event_complete(level_event_name, level_event_number):
	print("level event complete ", level_event_name, level_event_number)
	if level_event_number == 1:
		print("first level event completed, starting next event")
		
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		start_event_timer.set_wait_time(10.0)
		start_event_timer.set_one_shot(true)
		
		wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.set_wait_time(1.5)
		
		spawn_enemies_timer.set_name(event_name + "_spawn_enemies_timer")
		spawn_enemies_timer.connect("timeout", self, "_on_spawn_enemies_timer")
		spawn_enemies_timer.set_one_shot(false)
		spawn_enemies_timer.set_wait_time(0.1)
		
		spawn_platforms_timer.set_name(event_name + "_spawn_platforms_timer")
		spawn_platforms_timer.connect("timeout", self, "_on_spawn_platforms_timer")
		spawn_platforms_timer.set_one_shot(false)
		spawn_platforms_timer.set_wait_time(3.0)
		
		self.add_child(start_event_timer)
		self.add_child(wait_after_stopping_spawner_timer)
		self.add_child(spawn_enemies_timer)
		self.add_child(spawn_platforms_timer)
		
		start_event_timer.start()

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()

func trigger() -> void:
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func _on_spawn_platforms_timer() -> void:
	var platform_to_spawn : PackedScene = load(Events.get_level_platforms(1).get('LowPlatform3'))
	enemy_spawner._direct_spawn_obstacle_at_position(platform_to_spawn, platform_spawn_place, 500)
	num_platforms_spawned += 1
	if num_platforms_spawned >= 3 and !enemy_spawn_start:
		enemy_spawn_start = true
		spawn_enemies_timer.start()

func _on_spawn_enemies_timer() -> void:
	var enemy_to_spawn = load(Events.get_enemy_paths().get('Misbeehave'))
	enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 799), 1500)
	num_enemies_spawned += 1
	if num_enemies_spawned >= 30:
		spawn_enemies_timer.stop()
		spawn_platforms_timer.stop()
		end_event()

func event_start() -> void:
	if enemy_spawner != null:
		spawn_platforms_timer.start()
#		var enemy_to_spawn = load(Events.get_enemy_paths().get('Misbeehave'))
#		var platform_to_spawn = load(Events.get_level_platforms(1).get('LowPlatform3'))
#		enemy_spawner._direct_spawn_obstacle_at_position(platform_to_spawn, Vector2(2200, 420), 500)
#		enemy_spawner._direct_spawn_obstacle_at_position(platform_to_spawn, Vector2(2900, 420), 500)
#		enemy_spawner._direct_spawn_obstacle_at_position(platform_to_spawn, Vector2(3600, 420), 500)
		# enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 699), 1000)
		# enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2400, 699), 1000)
		# enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2600, 699), 1000)
		# enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2800, 699), 1000)
		#num_enemies_spawned = 4
		#end_event()
	else:
		print("enemy spawner is null")
		
func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
