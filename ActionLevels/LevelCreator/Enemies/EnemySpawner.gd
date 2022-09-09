extends Node2D

export (int) var max_enemies_on_screen = 4
export (float) var seconds_enemy_spawn_frequency = 1.0
export (Array, PackedScene) var enemy_list

onready var spawn_timer = Timer.new()
onready var enemies_spawned = 0
onready var rng = RandomNumberGenerator.new()

var enemy_to_spawn = null
var spawn_points = []

func _ready():
	rng.randomize()
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	Events.connect("level_spawn_points", self, "_on_level_spawn_points")
	spawn_timer.set_name("spawn_timer")
	spawn_timer.connect("timeout", self, "_spawn_enemy")
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))
	self.add_child(spawn_timer)
	spawn_timer.start()

func _on_level_spawn_points(_spawn_points):
	spawn_points = _spawn_points
	print("spawn points are ", spawn_points)
	
func _on_regular_enemy_death():
	enemies_spawned -= 1
	
func _spawn_enemy():
	rng.randomize()
	if enemies_spawned < max_enemies_on_screen:
		enemy_to_spawn_next()
		enemies_spawned += 1
	spawn_timer.set_wait_time(seconds_enemy_spawn_frequency + rng.randf_range(0.1, 0.6))

func enemy_to_spawn_next():
	rng.randomize()
	var num_enemies = enemy_list.size() - 1
	if num_enemies >= 1:
		var random_enemy = rng.randi_range(0, num_enemies)
		enemy_to_spawn = enemy_list[random_enemy]
		spawn_enemy_to_scene()
	else:
		print("no enemies found!")

func spawn_enemy_to_scene():
	var parent_node = self.get_parent()
	if parent_node != null:
		var _enemy_to_spawn = enemy_to_spawn.instance()
		rng.randomize()
		if spawn_points.size() > 0:
			_enemy_to_spawn.position = spawn_points[rng.randi_range(0, spawn_points.size() - 1)]
			parent_node.add_child(_enemy_to_spawn)
		else:
			print("No spawn points found!")
