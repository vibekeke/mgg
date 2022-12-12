extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")
export var enemy_to_spawn : PackedScene
onready var new_dialog = Dialogic.start('LevelTutorial_Event1')
onready var monitored_player = get_node("%RetroPlayer")
var current_tutorial_task = ''
var process_lock = false
var successful_jumps = 0
var start_event_timer = Timer.new()
var wait_after_stopping_spawner_timer = Timer.new()

func _ready():
	start_event_timer.set_name("LevelTutorial_Event1_start_timer")
	start_event_timer.connect("timeout", self, "trigger")
	start_event_timer.set_wait_time(0.5)
	start_event_timer.set_one_shot(true)
	wait_after_stopping_spawner_timer.set_name("Level1_Event1_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
	wait_after_stopping_spawner_timer.set_wait_time(1.5)
	self.add_child(start_event_timer)
	self.add_child(wait_after_stopping_spawner_timer)
	start_event_timer.start()
	event_number = 1
	event_name = 'LevelTutorial_Event1'

func _on_wait_after_stopping_spawner_timer():
	event_start()
	wait_after_stopping_spawner_timer.stop()
 
func jump_challenge():
	print(monitored_player.current_animation())
	if monitored_player.current_animation() == 'Landing' and !process_lock:
		process_lock = true
		successful_jumps = successful_jumps + 1
	if monitored_player.current_animation() == 'RisingLoop' and process_lock:
		process_lock = false
	# this is a hack, fix player animations to ensure this works correctly
	if successful_jumps > 4:
		current_tutorial_task = 'float_challenge'

func float_challenge():
	pass
	
func slide_challenge():
	pass

func shoot_challenge():
	pass

func dog_challenge():
	pass

func big_shot_challenge():
	pass

func trigger() -> void: 
	Events.emit_signal("level_event_lock", event_name, event_number)
	if enemy_spawner != null:
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func event_start() -> void:
	self.get_parent().add_child(new_dialog)
	current_tutorial_task = 'jump_challenge'

func _process(delta):
	if current_tutorial_task == 'jump_challenge':
		jump_challenge()



func end_event() -> void:
	print("Ending event")
	enemy_spawner.start_enemy_spawner()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
