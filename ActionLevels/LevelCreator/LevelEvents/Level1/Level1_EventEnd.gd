extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var dialog_layer = get_node("%DialogLayer")
onready var collected_dogs = []
var start_event_timer = Timer.new()
export var debug_mode : bool = false
var LEVEL_NAME = 'Level1'

func _ready():
	self.add_child(start_event_timer)
	event_number = 99
	event_name = 'Level1_EventEnd'
	Events.connect("collected_dog", self, "_on_collected_dog")
	if debug_mode:
		event_start()


func _on_collected_dog(dog_breed):
	if !collected_dogs.has(dog_breed):
		collected_dogs.append(dog_breed)

func _on_wait_after_stopping_spawner_timer():
	event_start()

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 6:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		start_event_timer.start()
		start_event_timer.set_wait_time(1.0)

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner.enemy_spawner_is_running():
		enemy_spawner.stop_enemy_spawner()
	if platform_spawner.platform_spawner_is_running():
		platform_spawner.stop_platform_spawner()

	event_start()
	
func event_start() -> void:
	print("Starting final event.")
	var saved_dogs_for_level = {1 : collected_dogs}
	Events.save_game(1, saved_dogs_for_level)
	Events.emit_signal("transition_to_scene", "DemoEndCredits", false)
	
func end_event() -> void:
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
