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
signal regular_enemy_death
signal level_spawn_points(spawn_points)
signal boss_spawned
signal level_complete

func _disable_player_actions(to_disable):
	# for tutorial and other stuff, e.g. boss loading?
	self.emit_signal("disable_player_action", to_disable)

func _disable_enemy_actions(to_disable):
	self.emit_signal("disable_enemy_action", to_disable)


func transition_to_new_scene(next_scene):
	self.emit_signal("transition_to_scene", next_scene)
