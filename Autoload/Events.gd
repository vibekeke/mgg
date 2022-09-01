extends Node

signal player_max_health(health) # emits players max health, NOT current health
signal player_damaged(damage) # when the player takes damage
signal player_current_health(health) # emits the current health of the player
signal collided_with_player(damage) # when an enemy collides with a player
signal player_global_position(global_position) # global position of the player
signal player_local_position(local_position)

signal game_over # player has died or game has ended for some other reason

signal dialogic_signal(transition_to)

signal disable_player_action(to_disable)
signal disable_enemy_action(to_disable)

func _disable_player_actions(to_disable):
	# for tutorial and other stuff, e.g. boss loading?
	self.emit_signal("disable_player_action", to_disable)

func _disable_enemy_actions(to_disable):
	self.emit_signal("disable_enemy_action", to_disable)

func _load_new_scene(level):
	print('level is', level)
	print("Load a new scene with fancy transitions etc here.")
