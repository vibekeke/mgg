extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)
export (Array, PackedScene) var droppables
export (NodePath) var take_damage
onready var take_damage_node = get_node(take_damage)

onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	take_damage_node.connect("enemy_dead", self, "_on_enemy_dead")

func _on_enemy_dead(node_id: int, death_position: Vector2):
	if rng.randi_range(0, 10) < 3 and droppables.size() > 0:
		var _collectible_to_spawn = droppables[randi() % droppables.size()].instance()
		_collectible_to_spawn.scroll_speed = 250
		_collectible_to_spawn.global_position = death_position
		print("spawning collectible!!!!!!")
		for node in get_tree().get_root().get_children():
			print("node is ", node)
			if node.is_in_group("level"):
				node.call_deferred("add_child", _collectible_to_spawn)
