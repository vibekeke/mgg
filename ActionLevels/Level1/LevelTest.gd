extends BaseLevelEvent

onready var level_event_1 = get_node("%Level1_Event1")
onready var level_event_timer = get_node("%LevelEventTimer")

var title = "level_test"
onready var level_event_list = [level_event_1]
onready var number_of_events = level_event_list.size()
var number_of_run_events := 0

func _ready():
	if number_of_events > 0:
		for level_event in level_event_list:
			level_event.visible = false
		var first_event = level_event_list[0]
		level_event_timer.wait_time = first_event.time_until_event
		level_event_timer.start()

func _on_LevelEventTimer_timeout():
	Events.emit_signal("enemy_spawner_enabled", false)
	Events.emit_signal("kill_spawned_enemies")
	Events.emit_signal("kill_enemy_bullet")
	level_event_list[number_of_run_events].visible = true
