extends Node

var completed_events_map = {}
var currently_running_event = -1
onready var total_events = self.get_children().size()
export var debug_trigger_event_number := 6

func _ready():
	Events.connect("level_event_lock", self, "_on_currently_running_event")
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	if debug_trigger_event_number > 0:
		disable_all_event_timers()
		call_deferred("debug_trigger_event", debug_trigger_event_number)

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

func debug_trigger_event(event_number: int):
	for child in get_children():
		if child.event_number == event_number:
			child.trigger()
			break

func disable_all_event_timers():
	for child in get_children():
		if child.has_method("get") and child.get("start_event_timer") != null:
			child.start_event_timer.stop()
