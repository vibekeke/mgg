extends Node

var current_level_stats: LevelStats = null

var notification_queue = []

func _ready():
	initialize()

func initialize():
	# Load challenge states from save file
	SaveFileManager.sync_to_stats_tracker()

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
	if no_float_run_completed:
		return
	if current_level_stats and current_level_stats.last_run_completed:
		if current_level_stats.player_performed_actions['float'] == 0:
			no_float_run_completed = true
			notification_queue.append("no_float_run")
			SaveFileManager.set_no_float_run_completed(true)

func no_damage_taken() -> void:
	if no_damage_taken_run_completed:
		return
	if current_level_stats and current_level_stats.last_run_completed:
		if ScoreManager.get_hits() == 0:
			no_damage_taken_run_completed = true
			notification_queue.append("no_damage_taken_run")
			SaveFileManager.set_no_damage_taken_run_completed(true)

func full_pacifist() -> void:
	if pacifist_run_completed:
		return
	if current_level_stats and current_level_stats.last_run_completed:
		if current_level_stats.killed_enemies == 0:
			pacifist_run_completed = true
			notification_queue.append("pacifist_run")
			SaveFileManager.set_pacifist_run_completed(true)
	
func high_score_over_threshold() -> void:
	if high_score_run_completed:
		return
	if current_level_stats and current_level_stats.last_run_completed:
		if ScoreManager.get_score() >= 3000:
			high_score_run_completed = true
			notification_queue.append("high_score_run")
			SaveFileManager.set_high_score_run_completed(true)

func drain_notification_queue() -> Array:
	var out = notification_queue.duplicate()
	notification_queue.clear()
	return out
	
