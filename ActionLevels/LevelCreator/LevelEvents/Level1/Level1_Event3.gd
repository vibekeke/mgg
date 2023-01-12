extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var start_event_timer = Timer.new()
onready var end_event_timer = Timer.new()
onready var wait_after_stopping_spawner_timer = Timer.new()
export var time_until_event_start = 3.0
export var debug_mode : bool = false

export var dog : PackedScene
export var bee : PackedScene

onready var dog_to_spawn = 'Golden'

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 3
	event_name = "Level1_Event3"
	if '1' in Events.COLLECTED_DOGS:
		if 'Golden' in Events.COLLECTED_DOGS.get('1'):
			print_debug("spawning clear dogu")
			dog_to_spawn = 'ClearDogu'
	if debug_mode:
		_on_level_event_complete('dummy_event', 2)

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 2:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		if debug_mode:
			time_until_event_start = 0.1
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)

		end_event_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		end_event_timer.connect("timeout", self, "end_event")
		end_event_timer.set_wait_time(3.0)
		end_event_timer.set_one_shot(true)

		wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.set_wait_time(1.0)
		wait_after_stopping_spawner_timer.set_one_shot(true)

		self.add_child(start_event_timer)
		self.add_child(end_event_timer)
		self.add_child(wait_after_stopping_spawner_timer)
		
		start_event_timer.start()

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()

func event_start() -> void:

	enemy_spawner._direct_spawn_at_position(bee, Vector2(2200, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(2350, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(2500, 799), 550)

	enemy_spawner._direct_spawn_at_position(bee, Vector2(3200, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(3350, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(3500, 799), 550)
	enemy_spawner._direct_spawn_dog(dog, dog_to_spawn, Vector2(3350, 930), 550 * 1.5, true)

	enemy_spawner._direct_spawn_at_position(bee, Vector2(4200, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(4350, 799), 550)
	enemy_spawner._direct_spawn_at_position(bee, Vector2(4500, 799), 550)
	
	end_event_timer.start()

func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.increment_difficulty_tier()
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
