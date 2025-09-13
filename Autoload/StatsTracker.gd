extends Node

var current_level_stats: LevelStats = null

func set_current_level(stats: LevelStats):
	current_level_stats = stats

func record_player_jump():
	if current_level_stats:
		current_level_stats.increment_player_jump()

func record_player_float():
	if current_level_stats:
		current_level_stats.increment_player_float()

func record_enemy_kill(enemy_environment: String):
	if current_level_stats:
		current_level_stats.increment_killed_enemies(enemy_environment)

func get_current_level_stats() -> LevelStats:
	return current_level_stats

## Level 1 challenges

var no_float_run_completed : bool = false
var no_damage_taken_run_completed : bool = false
var pacifist_run_completed : bool = false
var high_score_run_completed : bool = false

func calculate_level1_challenges() -> void:
	no_float_run()
	no_damage_taken()
	full_pacifist()
	high_score_over_threshold()

func no_float_run() -> void:
	if current_level_stats and current_level_stats.last_run_completed and !no_float_run_completed:
		no_float_run_completed = current_level_stats.player_performed_actions['float'] == 0

func no_damage_taken() -> void:
	if current_level_stats and current_level_stats.last_run_completed and !no_damage_taken_run_completed:
		no_damage_taken_run_completed = ScoreManager.get_hits() == 0

func full_pacifist() -> void:
	if current_level_stats and current_level_stats.last_run_completed and !pacifist_run_completed:
		pacifist_run_completed = current_level_stats.killed_enemies == 0
	
func high_score_over_threshold() -> void:
	if current_level_stats and current_level_stats.last_run_completed and !high_score_run_completed:
		high_score_run_completed = ScoreManager.get_score() >= 2500
