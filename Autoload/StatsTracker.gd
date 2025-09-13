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

func no_float_run() -> bool:
	if current_level_stats:
		return current_level_stats.player_performed_actions['float'] == 0
	return false

func no_damage_taken() -> bool:
	return ScoreManager.get_hits() == 0
	
func full_pacifist() -> bool:
	if current_level_stats:
		return current_level_stats.killed_enemies == 0
	return false
	
func high_score_over_threshold() -> bool:
	return ScoreManager.get_score() >= 2500
