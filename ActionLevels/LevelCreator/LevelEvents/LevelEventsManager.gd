extends Node

var completed_events_map = {}
var currently_running_event = -1
var level_started = false
@onready var total_events = self.get_children().size()
@export var debug_trigger_event_number := 6
@export var main_level_scene_path : NodePath
@onready var main_level = get_node_or_null(main_level_scene_path)

func _ready():
	Events.connect("level_event_lock", Callable(self, "_on_currently_running_event"))
	Events.connect("level_event_complete", Callable(self, "_on_level_event_complete"))
	
	# Connect to level start signal
	if main_level != null:
		main_level.connect('level_start', Callable(self, "_on_level_start"))
	else:
		print("No main level detected, events will not run")
	
	if debug_trigger_event_number > 0:
		disable_all_event_timers()

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
	if not level_started:
		print("Cannot trigger event ", event_number, " - level has not started yet")
		return
	
	for child in get_children():
		if child.event_number == event_number:
			print("TRIGGERING EVENT NUMBER ", child.event_number)
			child.trigger()
			break

func _on_level_start():
	level_started = true
	if debug_trigger_event_number > 0:
		# Debug mode - trigger the debug event
		debug_trigger_event(debug_trigger_event_number)
	else:
		# Normal mode - start Event 1
		start_event(1)

func start_event(event_number: int):
	if not level_started:
		print("Cannot start event ", event_number, " - level has not started yet")
		return
	
	for child in get_children():
		if child.event_number == event_number:
			if child.has_method("start_initial_event"):
				child.start_initial_event()
			break

func disable_all_event_timers():
	for child in get_children():
		if child.has_method("get") and child.get("start_event_timer") != null:
			child.start_event_timer.stop()
