extends Node

signal player_max_health(health) # emits players max health, NOT current health
signal player_damaged(damage) # when the player takes damage
signal player_current_health(health) # emits the current health of the player
signal collided_with_player(damage) # when an enemy collides with a player
signal player_global_position(global_position) # global position of the player
signal player_local_position(local_position)
signal game_over # player has died or game has ended for some other reason

func _process(delta):
	#print('FPS is ', str(Engine.get_frames_per_second()))
	pass
