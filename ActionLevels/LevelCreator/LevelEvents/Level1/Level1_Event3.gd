extends LevelEvent

onready var event_timer = Timer.new()
onready var enemy_spawner = get_node("%EnemySpawner")

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	event_number = 3
	event_name = 'Level1_Event3'

func _on_level_event_complete(level_event_name, level_event_number):
	pass

func trigger() -> void:
	pass
	
func event_start() -> void:
	pass
		
func end_event() -> void:
	pass
