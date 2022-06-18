extends Node2D

export (String) var level_name

export (float) var obstacle_spawn_freq
export (float) var enemy_spawn_freq

onready var rng = RandomNumberGenerator.new()

onready var obstacle_timer = Timer.new()
onready var enemy_timer = Timer.new()

func _ready(): 
	rng.randomize()
	obstacle_timer.connect("timeout", self, "_on_call_obstacle_spawner")
	obstacle_timer.set_wait_time(obstacle_spawn_freq)
	
	enemy_timer.connect("timeout", self, "_on_call_enemy_spawner")
	enemy_timer.set_wait_time(enemy_spawn_freq)
	
	add_child(enemy_timer)
	add_child(obstacle_timer)
	enemy_timer.start()
	obstacle_timer.start()

func _on_call_obstacle_spawner():
	$ObstacleSpawner.instance_default_for_level(level_name)
	var obstacle_spawn_fuzziness = rng.randf_range(-0.5, 0.5)
	obstacle_timer.set_wait_time(obstacle_spawn_freq + obstacle_spawn_fuzziness)

func _on_call_enemy_spawner():
	$EnemySpawner.instance_default_for_level(level_name)
	var enemy_spawn_fuzziness = rng.randf_range(-0.5, 0.5)
	enemy_timer.set_wait_time(enemy_spawn_freq + enemy_spawn_fuzziness)
	
