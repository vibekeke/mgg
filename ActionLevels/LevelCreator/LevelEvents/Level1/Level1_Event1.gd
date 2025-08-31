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

var preloaded_enemies = []

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
	
	_preload_all_objects()

func _preload_all_objects():
	print("Level1_Event1: Starting STRESS TEST preloading...")
	var start_time = OS.get_ticks_msec()
	
	# Preload normal enemies
	for i in range(3):
		var enemy = enemy_to_spawn.instance()
		enemy.visible = false
		enemy.set_process(false)
		preloaded_enemies.append(enemy)
	
	# STRESS TEST: Create a bunch of dummy objects and do heavy processing
	print("Level1_Event1: Creating 500 dummy objects for stress test...")
	var dummy_objects = []
	for i in range(500):
		var dummy = enemy_to_spawn.instance()
		dummy.visible = false
		dummy.set_process(false)
		dummy_objects.append(dummy)
		
		# Add some processing work every 50 objects
		if i % 50 == 0:
			_do_heavy_computation()
			print("Level1_Event1: Stress test progress: ", i, "/500")
	
	# Clean up dummy objects
	print("Level1_Event1: Cleaning up dummy objects...")
	for dummy in dummy_objects:
		dummy.queue_free()
	dummy_objects.clear()
	
	# Add final heavy computation
	print("Level1_Event1: Final heavy computation...")
	for j in range(3):
		_do_heavy_computation()
	
	# STRESS TEST: Add 20 second timer
	print("Level1_Event1: Starting 20 second timer...")
	yield(get_tree().create_timer(20.0), "timeout")
	print("Level1_Event1: 20 second timer finished!")
	
	var end_time = OS.get_ticks_msec()
	print("Level1_Event1: STRESS TEST complete - took ", end_time - start_time, "ms")
	print("Level1_Event1: Normal preloading complete - ", preloaded_enemies.size(), " enemies")
	
	# Signal that this event has finished loading
	mark_loading_complete()

func _do_heavy_computation():
	# Simulate heavy CPU work
	var result = 0
	for i in range(100000):
		result += sin(i) * cos(i) * tan(i * 0.1)
		if i % 10000 == 0:
			# Force a small delay to make it more noticeable
			yield(get_tree(), "idle_frame")

func _spawn_preloaded_enemy_at_position(position: Vector2, speed: int):
	if preloaded_enemies.size() > 0:
		var enemy = preloaded_enemies.pop_front()
		enemy.position = position
		enemy.initial_scroll_speed = speed
		enemy.visible = true
		enemy.set_process(true)
		enemy_spawner.get_parent().call_deferred("add_child", enemy)
		print("Level1_Event1: Spawned preloaded enemy at ", enemy.position)
	else:
		print("Level1_Event1: No more preloaded enemies available!")

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
		_spawn_preloaded_enemy_at_position(Vector2(2200, 699), 300)
		_spawn_preloaded_enemy_at_position(Vector2(2200, 799), 300)
		_spawn_preloaded_enemy_at_position(Vector2(2200, 899), 300)
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
		true,
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
