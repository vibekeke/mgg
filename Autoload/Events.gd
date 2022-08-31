extends Node

signal player_max_health(health) # emits players max health, NOT current health
signal player_damaged(damage) # when the player takes damage
signal player_current_health(health) # emits the current health of the player
signal collided_with_player(damage) # when an enemy collides with a player
signal player_global_position(global_position) # global position of the player
signal player_local_position(local_position)
signal game_over # player has died or game has ended for some other reason

signal dialogic_signal(transition_to)

func _ready():
	Events.connect("dialogic_signal", self, "_load_new_scene")

func _load_new_scene(level):
	print('level is', level)
	print("Load a new scene with fancy transitions etc here.")

func _process(delta):
	#print('FPS is ', str(Engine.get_frames_per_second()))
	pass
