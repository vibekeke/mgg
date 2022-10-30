extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
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
var platform_spawn_place = Vector2(2200, 420)
var enemy_spawn_place = Vector2(2200, 799)
var background_enemy_spawn_place = Vector2(0, 861)
var enemy_speed = 1500
var platform_scroll_speed = 500

export var enemy_to_spawn : PackedScene
export var background_element_to_spawn : PackedScene
export var platform_to_spawn : PackedScene

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 2
	event_name = "Level1_Event2"

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
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func _on_spawn_platforms_timer() -> void:
	enemy_spawner._direct_spawn_obstacle_at_position(platform_to_spawn, platform_spawn_place, platform_scroll_speed)
	if !background_enemy_spawn_start:
		background_enemy_spawn_start = true
		spawn_background_enemies_timer.start()
	num_platforms_spawned += 1
	if num_platforms_spawned >= 3 and !enemy_spawn_start:
		enemy_spawn_start = true
		spawn_enemies_timer.start()

func _on_spawn_background_enemies_timer() -> void:
	enemy_spawner.spawn_to_background_element(background_element_to_spawn, 'BackForestBackground', background_enemy_spawn_place, enemy_speed)
	num_background_enemies_spawned += 1
	if num_background_enemies_spawned >= 20:
		spawn_background_enemies_timer.stop()

func _on_spawn_enemies_timer() -> void:
	enemy_spawner._direct_spawn_at_position(enemy_to_spawn, enemy_spawn_place, enemy_speed)
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
	enemy_spawner.increment_difficulty_tier()
	Events.emit_signal("level_event_complete", event_name, event_number)
	self.queue_free()
