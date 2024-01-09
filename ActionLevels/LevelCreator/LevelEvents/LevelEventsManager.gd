extends Node

var completed_events_map = {}
var currently_running_event = -1
onready var total_events = self.get_children().size()
#onready var enemy_spawner = get_node("%EnemySpawner")
var a = 0
func _ready():
	Events.connect("level_event_lock", self, "_on_currently_running_event")
	Events.connect("level_event_complete", self, "_on_level_event_complete")

func _on_currently_running_event(level_event_name, level_event_number):
	currently_running_event = level_event_number

func _on_level_event_complete(level_event_name, level_event_number):
	completed_events_map[level_event_number] = level_event_name

func get_is_event_running():
	return !(currently_running_event < 0)

func get_currently_running_event():
	return currently_running_event

func completed_events():
	return completed_events_map

#func _process(delta):
#	print("an event is running ", get_is_event_running(), " the event is ", get_currently_running_event())
