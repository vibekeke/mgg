extends Node2D

onready var enemy_spawner = get_node("%EnemySpawner")

func load_events():
	pass

func _ready():
	if enemy_spawner != null:
		## unique level event can be:
		## spawning unique enemy waves or bosses
		## starting a cutscene/gameplay dialogue event
		print("stopping enemy spawner for unique level event")
		enemy_spawner.stop_enemy_spawner()
