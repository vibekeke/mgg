class_name SaveFile
extends Reference

# Basic save metadata
var save_owner : String = ""
var save_location : String = ""
var save_created_at : String = ""
var save_version : int = 1

# Challenge completion flags from StatsTracker
var no_float_run_completed : bool = false
var no_damage_taken_run_completed : bool = false
var pacifist_run_completed : bool = false
var high_score_run_completed : bool = false

# Additional persistent game flags
var has_beaten_first_stage_before : bool = false
var first_time_playing : bool = true
var all_dogs_collected : bool = false

# High score
var high_score : int = 0

func _init():
	save_created_at =  Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(true), false)
	save_version = 1

func to_dict() -> Dictionary:
	return {
		"save_version": save_version,
		"save_created_at": save_created_at,
		"has_beaten_first_stage_before": has_beaten_first_stage_before,
		"no_float_run_completed": no_float_run_completed,
		"no_damage_taken_run_completed": no_damage_taken_run_completed,
		"pacifist_run_completed": pacifist_run_completed,
		"high_score_run_completed": high_score_run_completed,
		"first_time_playing": first_time_playing,
		"all_dogs_collected": all_dogs_collected,
		"high_score": high_score
	}

func from_dict(data: Dictionary) -> bool:
	# Validate required fields
	if not data.has("save_version"):
		print("SaveFile: Missing save_version")
		return false

	save_version = data.get("save_version", 1)
	save_created_at = data.get("save_created_at", "")
	has_beaten_first_stage_before = data.get("has_beaten_first_stage_before", false)
	no_float_run_completed = data.get("no_float_run_completed", false)
	no_damage_taken_run_completed = data.get("no_damage_taken_run_completed", false)
	pacifist_run_completed = data.get("pacifist_run_completed", false)
	high_score_run_completed = data.get("high_score_run_completed", false)
	first_time_playing = data.get("first_time_playing", true)
	all_dogs_collected = data.get("all_dogs_collected", false)
	high_score = data.get("high_score", 0)

	return true
