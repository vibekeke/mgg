extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
export var enemy_to_spawn : PackedScene
onready var new_dialog = Dialogic.start('Level1Event1')
var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()

func _ready():
	start_event_timer.set_name("Level1_Event1_start_timer")
	start_event_timer.connect("timeout", self, "trigger")
	start_event_timer.set_wait_time(5.0)
	wait_after_stopping_spawner_timer.set_name("Level1_Event1_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.set_wait_time(1.5)
	self.add_child(start_event_timer)
	self.add_child(wait_after_stopping_spawner_timer)
	start_event_timer.start()
	event_number = 1
	event_name = 'Level1_Event1'

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()

func trigger() -> void:
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func event_start() -> void:
	if enemy_spawner != null:
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 699), 300)
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 799), 300)
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 899), 300)

		self.get_parent().add_child(new_dialog)
		end_event()
	else:
		print("enemy spawner is null")
		
func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	self.queue_free()
