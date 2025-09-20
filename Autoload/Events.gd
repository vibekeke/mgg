extends Node

# player related actions
signal player_max_health(health) # emits players max health, NOT current health
signal player_damaged(damage) # when the player takes damage
signal player_current_health(health) # emits the current health of the player
signal collided_with_player(damage) # when an enemy collides with a player
signal player_global_position(global_position) # global position of the player
signal player_local_position(local_position)
signal has_charge_shot # whether player has charge shot or not
signal fired_charge_shot # charge shot has just been fired
signal player_standing(standing)
signal player_invincible(invincible)

# game state, e.g. scene transitions, game overs, cutscenes
signal transition_to_scene(to_scene, to_dialogue_screen)
signal game_over # player has died or game has ended for some other reason
signal disable_player_action(to_disable)
signal disable_enemy_action(to_disable)

# collectibles
signal collected_star
signal collected_heart
signal collected_dog(dog_type)

signal collected_all_dogs

signal score_popup_requested(collectible_type, position)

# level related
signal enemy_taken_damage(enemy, health_value)
signal regular_enemy_death
signal big_bird_boss_defeated(death_position)
signal enemy_despawned
signal level_spawn_points(spawn_points)
signal boss_spawned
signal level_event_lock(level_event_name, event_number)
signal level_event_complete(level_event_name, event_number)
signal level_complete
signal background_element_offscreen(element_name)
signal tutorial_element_touched(element_id)
signal in_battle_dialogue(_in_battle_dialogue, enemy_name)
signal dialogue_intro_finished
signal pacifist_successful

signal back_to_stage_from_dialogue_intro

# overworld related
signal overworld_player_controlled(status)
signal bedroom_lights_on(status)

signal kill_enemy_bullet
signal pause_level

# new enemy spawner
signal enemy_spawner_enabled(enabled)
signal enemy_spawner_difficulty(time_to_spawn, max_enemies)
signal kill_spawned_enemies

# new platform spawner
signal platform_spawner_enabled(enabled)
signal platform_spawn_number(number_of_platforms)
signal kill_spawned_platforms
signal platform_despawned
signal platform_return_to_pool(platform)

#level background
signal background_moving_enabled(enabled)

# ui
signal fall_down_ui
signal go_up_ui

# pausing
signal pausing_allowed(pause_allowed)

# save file location and metadata
const SAVE_FILE_LOCATION : String = "res://mggsave.save"
const COMPLETED_LEVELS : Array = []
var COLLECTED_DOGS : Dictionary = {}
var dogs_complete = false  
var first_time_playing = true


var is_initialized : bool = false

func _ready():
	randomize()
	OS.min_window_size = Vector2(1280, 720)
	OS.max_window_size = Vector2(1920, 1080)
	OS.center_window()
	initialize()

func initialize():
	if is_initialized:
		return
	# Ensure SaveFileManager is initialized first
	SaveFileManager.initialize()

	# Now load persistent variables
	first_time_playing = SaveFileManager.get_first_time_playing()
	dogs_complete = SaveFileManager.get_all_dogs_collected()
	is_initialized = true
	print("Events: Loaded from save: first_time_playing = ", first_time_playing, ", dogs_complete = ", dogs_complete)

func _disable_player_actions(to_disable: bool):
	# for tutorial and other stuff, e.g. boss loading?
	self.emit_signal("disable_player_action", to_disable)

func _disable_enemy_actions(to_disable):
	self.emit_signal("disable_enemy_action", to_disable)


func transition_to_new_scene(next_scene):
	self.emit_signal("transition_to_scene", next_scene, true)
	
func go_to_game_over():
	AudioManager.fade_out_music(1.0)
	self.emit_signal("transition_to_scene", "GameOver", true)


onready var enemyPaths = {
	'Misbeehave': 'res://ActionLevels/LevelCreator/Enemies/Misbeehave/Misbeehave.tscn',
	'BroBun': 'res://ActionLevels/LevelCreator/Enemies/BroBun/BroBun.tscn',
	'BroBear': 'res://ActionLevels/LevelCreator/Enemies/BroBun/BroBun.tscn',
	'Gunnerfly': 'res://ActionLevels/LevelCreator/Enemies/Gunnerfly/Gunnerfly.tscn',
	'OurGuy': 'res://ActionLevels/LevelCreator/Enemies/OurGuy/OurGuy.tscn',
	'Satan': 'res://ActionLevels/LevelCreator/Enemies/Satan/Satan.tscn',
	'PathedMisbeehave': 'res://ActionLevels/LevelCreator/Enemies/PathedMisbeehave/PathedMisbeehave.tscn',
	'SneakySnake': 'res://ActionLevels/LevelCreator/Enemies/SneakySnake/SneakySnake.tscn',
	'BigBird': 'res://ActionLevels/LevelCreator/Bosses/BigBird/BigBird.tscn'
}

onready var level_collectibles = {
	'Star': 'res://ActionLevels/LevelCreator/LevelElements/Collectibles/Star.tscn',
	'CollectibleHeart': 'res://ActionLevels/LevelCreator/LevelElements/Collectibles/CollectibleHeart.tscn',
	'Dogu': 'res://ActionLevels/LevelCreator/LevelElements/Collectibles/Dogu.tscn'
}

onready var level_background_elements = {
	1 : {
		'BeeBackground': 'res://ActionLevels/LevelCreator/LevelElements/BackgroundElements/Level1/BeeBackground.tscn',
		'BigBackground': 'res://ActionLevels/LevelCreator/LevelElements/BackgroundElements/Level1/BigBackground.tscn'
	}
}

onready var level_platforms = {
	1 : {
		'LongTallPlatform': 'res://ActionLevels/LevelCreator/Obstacles/Forest/LongTallPlatform.tscn',
		'TallPlatform': 'res://ActionLevels/LevelCreator/Obstacles/Forest/TallPlatform.tscn',
		'LowPlatform1': 'res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform1.tscn',
		'LowPlatform2': 'res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform2.tscn',
		'LowPlatform3': 'res://ActionLevels/LevelCreator/Obstacles/Forest/LowPlatform3.tscn'
	}
}

onready var bossPaths = {
	'BigBird': 'res://ActionLevels/LevelCreator/Bosses/BigBird/BigBird.tscn'
}

onready var action_level_list = {
	"Level1": "res://ActionLevels/Level1/Level1_Forest.tscn",
	"Level2": "res://ActionLevels/Level2/Level2_Beach.tscn",
	"Level3": "res://ActionLevels/Level3/Level3_City.tscn",
	"GameOver": "res://Menus/GameOver.tscn"
}

func load_game():
	var loaded_save_game = File.new()
	if not loaded_save_game.file_exists(SAVE_FILE_LOCATION):
		print_debug("No save file found.")
		return
	loaded_save_game.open(SAVE_FILE_LOCATION, File.READ)
	while loaded_save_game.get_position() < loaded_save_game.get_len():
		var node_data = parse_json(loaded_save_game.get_line())
		var last_completed_level : int = node_data['LastCompletedLevel']
		var dog_info : Dictionary = node_data['collected_dogs_for_level']
		for x in range(0, last_completed_level):
			COMPLETED_LEVELS.append(x + 1)
		COLLECTED_DOGS = node_data['collected_dogs_for_level']

func save_game(level_name : int, dog_info : Dictionary):
	var save_dict = {
		'LastCompletedLevel': level_name,
		'collected_dogs_for_level': dog_info
	}

	var save_file = File.new()
	save_file.open(SAVE_FILE_LOCATION,  File.WRITE)
	save_file.store_line(to_json(save_dict))
	save_file.close()

func update_dogs(dog_type: String):
	if not COLLECTED_DOGS.has(dog_type):
		COLLECTED_DOGS[dog_type] = true
	if COLLECTED_DOGS.size() >= 3:
		dogs_complete = true
		SaveFileManager.set_all_dogs_collected(true)
		self.emit_signal("collected_all_dogs")
		

func get_boss(boss_name : String):
	return bossPaths[boss_name]

func get_enemy_paths():
	return enemyPaths

func get_level_platforms(level_number : int):
	return level_platforms[level_number]

func get_level_background_elements(level_number: int):
	return level_background_elements[level_number]

func get_level_collectible(collectible: String):
	return level_collectibles[collectible]

### Shaders

func set_vhs_shader(shader_params : Dictionary, vhs_filter: ColorRect):
	for param in shader_params:
		vhs_filter.material.set_shader_param(param, shader_params[param])

var vhs_filter_state_paused = {
	'overlay': true,
	'scanlines_opacity': 0.557,
	'scanlines_width': 0.128,
	'grille_opacity': 0.3,
	'resolution': Vector2(1920, 1080),
	'pixelate': true,
	'roll': true,
	'roll_speed': 1.2,
	'roll_size': 14.963,
	'roll_variation': 1.737,
	'distort_intensity': 0.034,
	'noise_opacity': 0.65,
	'noise_speed': 5,
	'static_noise_intensity': 0.06,
	'aberration': 0.007,
	'brightness': 1.2,
	'discolor': false,
	'warp_amount': 0,
	'clip_warp': false,
	'vignette_intensity': 0.4,
	'vignette_opacity': 0.256
}

var vhs_filter_state_unpaused = {
	'overlay': true,
	'scanlines_opacity': 0,
	'scanlines_width': 0,
	'grille_opacity': 0,
	'resolution': Vector2(1920, 1080),
	'pixelate': false,
	'roll': false,
	'roll_speed': 0.0,
	'roll_size': 0,
	'roll_variation': 0,
	'distort_intensity': 0.0,
	'noise_opacity': 0.0,
	'noise_speed': 0,
	'static_noise_intensity': 0.0,
	'aberration': 0.005,
	'brightness': 1.1,
	'discolor': false,
	'warp_amount': 0,
	'clip_warp': false,
	'vignette_intensity': 0.0,
	'vignette_opacity': 0.0
}
