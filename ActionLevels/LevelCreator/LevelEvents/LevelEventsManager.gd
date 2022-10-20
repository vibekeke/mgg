extends Node

export (Array, PackedScene) var events_list
onready var enemy_spawner = get_node("%EnemySpawner")

func _ready():
	print("enemy spawner in events manager ", enemy_spawner)
#	for event in self.get_children():
#		self.add_child(event.instance())
