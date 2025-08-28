extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
onready var platform_spawner = get_node("%PlatformSpawner")
onready var dialog_layer = get_node("%DialogLayer")
export var main_level_scene_path : NodePath
onready var main_level = get_node_or_null(main_level_scene_path)
export var enemy_to_spawn : PackedScene
export var level1_event1_dialog : Resource
var START_EVENT_WAIT_TIME = 5.0
# onready var new_dialog = Dialogic.start('Level1Event1', '', "res://addons/dialogic/Nodes/DialogNode.tscn", false)
var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()

func _ready():
	if main_level != null:
		main_level.connect('level_start', self, "_on_level_start")
	else:
		print("No level detected in path, events will not run")
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	start_event_timer.set_name("Level1_Event1_start_timer")
	start_event_timer.connect("timeout", self, "trigger")
	start_event_timer.set_wait_time(START_EVENT_WAIT_TIME)
	start_event_timer.one_shot = true
	wait_after_stopping_spawner_timer.set_name("Level1_Event1_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.set_wait_time(1.5)
	self.add_child(start_event_timer)
	self.add_child(wait_after_stopping_spawner_timer)
	event_number = 1
	event_name = 'Level1_Event1'

func start_initial_event():
	start_event_timer.start()

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()

func trigger() -> void:
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null and platform_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		platform_spawner.stop_platform_spawner()
		wait_after_stopping_spawner_timer.start()
	else:
		printerr("One of the spawners was not detected. Something has gone wrong here")

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
		Color(0.0, 0.0, 0.0, 0.25),
		false,
		1.5
		)

func _on_dialogue_box_finished(node_id):
	print("dialogue finished, node_id: ", node_id, ", self.get_instance_id(): ", self.get_instance_id())
	if self.get_instance_id() == node_id:
		yield(get_tree().create_timer(2.0), "timeout")
		end_event()

func end_event() -> void:
	start_event_timer.stop()
	enemy_spawner.start_enemy_spawner()
	platform_spawner.start_platform_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
	
func _on_level_start() -> void:
	start_initial_event()
