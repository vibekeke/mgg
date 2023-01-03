extends LevelEvent

onready var dialog_layer = get_node("%DialogLayer")
onready var collected_dogs = []
#onready var new_dialog = Dialogic.start('Level1Event1', '', "res://addons/dialogic/Nodes/DialogNode.tscn", false)
var start_event_timer = Timer.new()
export var debug_mode : bool = false
var LEVEL_NAME = 'Level1'

func _ready():
	self.add_child(start_event_timer)
	event_number = 99
	event_name = 'Level1_EventEnd'
	Events.connect("collected_dog", self, "_on_collected_dog")
	if debug_mode:
		print("saving immediately")
		event_start()


func _on_collected_dog(dog_breed):
	if !collected_dogs.has(dog_breed):
		collected_dogs.append(dog_breed)

func _on_wait_after_stopping_spawner_timer():
	event_start()

func save():
	print_debug("attempting to save game")
	var save_dict = {
		'LastCompletedLevel': LEVEL_NAME,
		'collected_dogs_for_level': {
			LEVEL_NAME: collected_dogs
		}
	}
	var save_game = File.new()
	save_game.open("res://savegame.save", File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == 6:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		start_event_timer.start()
		start_event_timer.set_wait_time(1.0)

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	event_start()
	
func event_start() -> void:
	save()
	
func end_event() -> void:
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
