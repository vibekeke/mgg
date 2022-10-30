extends LevelEvent

export var debug_mode : bool = false

onready var enemy_spawner = get_node("%EnemySpawner")
export var time_until_event_start = 1.0
export var ourguy : PackedScene
export var ourguybackground : PackedScene
export var platform_to_spawn_one : PackedScene
export var platform_to_spawn_two : PackedScene
var background_enemy_spawn_place = Vector2(0, 861)
var enemy_speed = 100

onready var start_event_timer = Timer.new()

# makes our guy run in the background for some time then spawns the enemy

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 4
	event_name = "Level1_Event4"
	if debug_mode:
		_on_level_event_complete('dummy_event', 3)

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 3:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		if debug_mode:
			time_until_event_start = 0.1 
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)
		self.add_child(start_event_timer)
		start_event_timer.start()

func trigger() -> void:
	event_start()

func event_start() -> void:
	enemy_spawner.spawn_to_background_element(ourguybackground, 'BackForestBackground', background_enemy_spawn_place, enemy_speed)
	enemy_spawner.add_enemy_to_spawn_list(ourguy, 1)
	end_event()

func end_event() -> void:
	start_event_timer.stop()
	Events.emit_signal("level_event_complete", event_name, event_number)
	self.queue_free()
