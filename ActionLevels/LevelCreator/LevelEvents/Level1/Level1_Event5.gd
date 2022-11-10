extends LevelEvent

export var debug_mode : bool = false

onready var enemy_spawner = get_node("%EnemySpawner")

# Enemies
export var background_brobun : PackedScene
export var background_brobear : PackedScene
export var background_dog : PackedScene

export var bun : PackedScene
export var bear : PackedScene
export var dog : PackedScene

var first_background_enemy_spawn_place : Vector2 = Vector2(-206, 378)
var second_background_enemy_spawn_place : Vector2 = Vector2(-206, 811)
var background_dog_spawn_place : Vector2 = Vector2(-206, 600)

var first_enemy_spawn_place : Vector2 = Vector2(2350, 100)
var second_enemy_spawn_place : Vector2 = Vector2(2350, 700)
var dog_collectible_spawn_place : Vector2 = Vector2(2150, 450)

var element_speed = 600
var background_element_speed = 100

var num_background_elements_offscreen = 0

var spawned_element_speed = 600

# Timers
onready var start_event_timer = Timer.new()
onready var wait_for_spawn_restart_timer = Timer.new()
export var time_until_event_start : float = 1.0

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	Events.connect("background_element_offscreen", self, "_on_background_element_offscreen")
	event_number = 5
	event_name = "Level1_Event5"
	if debug_mode:
		_on_level_event_complete('dummy_event', 4)
		
func _on_background_element_offscreen(element_name):
	if element_name == DataClasses.Enemies.SPACE_ANIMAL:
		num_background_elements_offscreen += 1
		if num_background_elements_offscreen >= 2:
			enemy_spawner.stop_enemy_spawner()
			spawn_space_animals()

func spawn_space_animals():
	enemy_spawner._direct_spawn_at_position(bear, first_enemy_spawn_place, spawned_element_speed)
	enemy_spawner._direct_spawn_dog(dog, 'Russel', dog_collectible_spawn_place, spawned_element_speed, true)
	enemy_spawner._direct_spawn_at_position(bun, second_enemy_spawn_place, spawned_element_speed)
	wait_for_spawn_restart_timer.start()

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 4:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		if debug_mode:
			time_until_event_start = 0.1
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)
		self.add_child(start_event_timer)
		start_event_timer.start()

		wait_for_spawn_restart_timer.set_name(event_name + "_wait_for_spawn_restart_timer")
		wait_for_spawn_restart_timer.connect("timeout", self, "end_event")
		wait_for_spawn_restart_timer.set_wait_time(2.5)
		self.add_child(wait_for_spawn_restart_timer)

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	event_start()

func event_start() -> void:
	enemy_spawner.spawn_to_background_element(background_dog, 'BackForestBackground', background_dog_spawn_place, background_element_speed)
	enemy_spawner.spawn_to_background_element(background_brobun, 'BackForestBackground', first_background_enemy_spawn_place, background_element_speed)
	enemy_spawner.spawn_to_background_element(background_brobear, 'BackForestBackground', second_background_enemy_spawn_place, background_element_speed)

func end_event() -> void:
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	enemy_spawner.add_enemy_to_spawn_list(bear, 1)
	enemy_spawner.add_enemy_to_spawn_list(bun, 1)
	enemy_spawner.start_enemy_spawner()
	self.queue_free()
