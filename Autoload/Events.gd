extends Node

signal player_max_health(health) # emits players max health, NOT current health
signal player_damaged(damage) # when the player takes damage
signal player_current_health(health) # emits the current health of the player
signal collided_with_player(damage) # when an enemy collides with a player

signal game_over # player has died or game has ended for some other reason
