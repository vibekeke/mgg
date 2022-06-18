extends Node2D

export (String) var level_name
export (float) var obstacle_spawn_freq
onready var rng = RandomNumberGenerator.new()
onready var timer = Timer.new()

func _ready(): 
	rng.randomize()
	timer.connect("timeout", self, "_on_call_obstacle_spawner")
	timer.set_wait_time(obstacle_spawn_freq)
	add_child(timer)
	timer.start()

func _on_call_obstacle_spawner():
	$ObstacleSpawner.instance_default_for_level(level_name)
	var obstacle_spawn_fuzziness = rng.randf_range(-0.5, 0.5)
	timer.set_wait_time(obstacle_spawn_freq + obstacle_spawn_fuzziness)
