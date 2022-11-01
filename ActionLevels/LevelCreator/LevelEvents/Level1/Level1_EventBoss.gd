extends LevelEvent

onready var enemy_spawner = get_node("%EnemySpawner")

# timers
onready var start_event_timer = Timer.new()
onready var end_event_timer = Timer.new()
onready var wait_after_stopping_spawner_timer = Timer.new()
onready var boss_background_swoop_timer = Timer.new()

onready var boss_background_to_spawn : Object = preload("res://ActionLevels/LevelCreator/LevelElements/BackgroundElements/Level1/BigBackground.tscn").instance()
onready var boss : PackedScene = preload("res://ActionLevels/LevelCreator/Bosses/BigBird/BigBird.tscn")
var boss_dialog = null
var background_boss_spawn_place = Vector2(-500, 700)
var background_boss_speed = 2000
export var time_until_event_start = 3.0
export var previous_event : int
export var debug_mode : bool = false

func _ready():
	Events.connect("level_event_complete", self, "_on_level_event_complete")
	Events.connect("background_element_offscreen", self, "_on_background_element_offscreen")
	boss_dialog = Dialogic.start('Level1BossIntroEvent')
	boss_dialog.connect("timeline_end", self, "_on_timeline_end")
	event_number = 99 # last level event
	event_name = "Level1_EventBoss"
	if debug_mode:
		_on_level_event_complete('dummy_event', previous_event)

func _on_timeline_end(_timeline_name):
	spawn_boss()
	

func _on_level_event_complete(level_event_name, level_event_number) -> void:
	if level_event_number == previous_event:
		start_event_timer.set_name(event_name + "_start_timer")
		start_event_timer.connect("timeout", self, "trigger")
		if debug_mode:
			time_until_event_start = 0.1
		start_event_timer.set_wait_time(time_until_event_start)
		start_event_timer.set_one_shot(true)

		end_event_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		end_event_timer.connect("timeout", self, "end_event")
		end_event_timer.set_wait_time(3.0)
		end_event_timer.set_one_shot(true)	

		wait_after_stopping_spawner_timer.set_name(event_name + "_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.connect("timeout", self, "_on_wait_after_stopping_spawner_timer")
		wait_after_stopping_spawner_timer.set_wait_time(1.0)
		wait_after_stopping_spawner_timer.set_one_shot(true)

		self.add_child(start_event_timer)
		self.add_child(end_event_timer)
		self.add_child(wait_after_stopping_spawner_timer)
		
		start_event_timer.start()

func trigger() -> void:
	if enemy_spawner != null:
		Events.emit_signal("level_event_lock", event_name, event_number)
		enemy_spawner.stop_enemy_spawner()
		wait_after_stopping_spawner_timer.start()

func _on_wait_after_stopping_spawner_timer():
	wait_after_stopping_spawner_timer.stop()
	event_start()

func _on_background_element_offscreen(element_name):
	if element_name == DataClasses.Boss.BIG_BIRD:
		self.get_parent().add_child(boss_dialog)

func spawn_boss():
	enemy_spawner.kill_non_boss_enemies()
	enemy_spawner._direct_spawn_boss_at_position(boss, Vector2(1510, 620), 0)

func event_start() -> void:

	if boss_background_to_spawn != null:
		boss_background_to_spawn.scale.x = 0.65
		boss_background_to_spawn.scale.y = 0.65
		enemy_spawner.spawn_instanced_background_element(boss_background_to_spawn, 'BackForestBackground', background_boss_spawn_place, background_boss_speed)
	#end_event_timer.start()

func end_event() -> void:
	start_event_timer.stop()
	Events.emit_signal("level_event_complete", event_name, event_number)
	Events.emit_signal("level_event_lock", "", -1)
	self.queue_free()
