extends BaseLevelEvent

onready var level_event_1 = get_node("%Level1_Event1")
onready var level_event_timer = get_node("%LevelEventTimer")
onready var level_background = get_node("%LevelBackground")
onready var background_big_bird = preload("res://ActionLevels/LevelCreator/DumbActors/BackgroundBigBird/BackgroundBigBird.tscn")
onready var enemy_spawner = get_node("%EnemySpawnerNew")
onready var platform_spawner = get_node("%PlatformSpawnerNew")
export var legacy_version : bool = false
var title = "level_test"
onready var level_event_list = [level_event_1]
onready var number_of_events = level_event_list.size()
var number_of_run_events := 0

func _ready():
	# call this when level intro is finished instead
	if legacy_version:
		setup_level_events()
		add_big_bird_to_background()
		Events.emit_signal("player_standing", false)
		Events.emit_signal("background_moving_enabled", true)
	
func setup_level_events():
	if number_of_events > 0:
		for level_event in level_event_list:
			level_event.visible = false
		var first_event = level_event_list[0]
		level_event_timer.wait_time = first_event.time_until_event
		level_event_timer.start()

func add_big_bird_to_background():
	var big_bird_background_instance = background_big_bird.instance()
	# big_bird_background_instance.scale = Vector2((big_bird_background_instance.scale.x * 0.25) * -1, big_bird_background_instance.scale.y * 0.25)
	big_bird_background_instance.scale = Vector2(0.2, 0.2)
	big_bird_background_instance.global_position = Vector2(big_bird_background_instance.speed * -1, 400)
	level_background.get_hill_background_node().add_child(big_bird_background_instance)

func _on_LevelEventTimer_timeout():
	Events.emit_signal("enemy_spawner_enabled", false)
	Events.emit_signal("platform_spawner_enabled", false)
	Events.emit_signal("kill_spawned_enemies")
	Events.emit_signal("kill_enemy_bullet")
	level_event_list[number_of_run_events].visible = true
