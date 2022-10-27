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

# game state, e.g. scene transitions, game overs, cutscenes
signal transition_to_scene(to_scene)
signal game_over # player has died or game has ended for some other reason
signal disable_player_action(to_disable)
signal disable_enemy_action(to_disable)

# collectibles
signal collected_star
signal collected_heart
signal collected_dog(dog_type)

# level related
signal enemy_taken_damage(enemy, health_value)
signal regular_enemy_death
signal level_spawn_points(spawn_points)
signal boss_spawned
signal level_event_complete(level_event_name, event_number)
signal level_complete
signal background_element_offscreen(element_name)


func _disable_player_actions(to_disable):
	# for tutorial and other stuff, e.g. boss loading?
	self.emit_signal("disable_player_action", to_disable)

func _disable_enemy_actions(to_disable):
	self.emit_signal("disable_enemy_action", to_disable)


func transition_to_new_scene(next_scene):
	self.emit_signal("transition_to_scene", next_scene)


onready var enemyPaths = {
	'Misbeehave': 'res://ActionLevels/LevelCreator/Enemies/Misbeehave/Misbeehave.tscn',
	'BroBun': 'res://ActionLevels/LevelCreator/Enemies/BroBun/BroBun.tscn',
	'BroBear': 'res://ActionLevels/LevelCreator/Enemies/BroBun/BroBun.tscn',
	'Gunnerfly': 'res://ActionLevels/LevelCreator/Enemies/Gunnerfly/Gunnerfly.tscn',
	'OurGuy': 'res://ActionLevels/LevelCreator/Enemies/OurGuy/OurGuy.tscn',
	'Satan': 'res://ActionLevels/LevelCreator/Enemies/Satan/Satan.tscn',
	'PathedMisbeehave': 'res://ActionLevels/LevelCreator/Enemies/PathedMisbeehave/PathedMisbeehave.tscn',
	'SneakySnake': 'res://ActionLevels/LevelCreator/Enemies/SneakySnake/SneakySnake.tscn',
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
