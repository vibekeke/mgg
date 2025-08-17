extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var dialog_layer = get_node("%DialogLayer")
export var enemy_to_spawn : PackedScene
export var level1_event1_dialog : Resource
var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	start_event_timer.set_name("Level1_Event1_start_timer")
	start_event_timer.connect("timeout", self, "trigger")
	start_event_timer.set_wait_time(5.0)
	start_event_timer.one_shot = true
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
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func event_start() -> void:
	if enemy_spawner != null:
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 699), 300)
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 799), 300)
		enemy_spawner._direct_spawn_at_position(enemy_to_spawn, Vector2(2200, 899), 300)
		display_dialogue()
	else:
		print("enemy spawner is null")
		
func display_dialogue():
	print("Creating dialogue balloon for level1_event1")
	MggDialogue.create_dialogue_balloon(
		"level1_event1", 
		level1_event1_dialog, 
		self.get_instance_id(), 
		DataClasses.Placement.LOWER, 
		DataClasses.CharacterPortrait.AngelIntense,
		Color(0.12549, 0.619608, 1, 0.25),
		Color(0.0, 0.0, 0.0, 0.25)
		)

func _on_dialogue_box_finished(node_id):
	print("dialogue finished, node_id: ", node_id, ", self.get_instance_id(): ", self.get_instance_id())
	if self.get_instance_id() == node_id:
		yield(get_tree().create_timer(2.0), "timeout")
		end_event()

func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
