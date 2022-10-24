extends Node

var completed_events_map = {}
onready var total_events = self.get_children().size()
onready var enemy_spawner = get_node("%EnemySpawner")

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	print("total number of events ", total_events)
	
func _on_level_event_complete(level_event_name, level_event_number):
	completed_events_map[level_event_number] = level_event_name
	print("currently compeleted events are ", completed_events_map)

func completed_events():
	return completed_events_map
