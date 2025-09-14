class_name SaveFile
extends Resource

# Basic save metadata
export var save_owner : String = ""
export var save_location : String = ""
export var save_created_at : String = ""
export var save_version : int = 1

# Challenge completion flags from StatsTracker
export var no_float_run_completed : bool = false
export var no_damage_taken_run_completed : bool = false
export var pacifist_run_completed : bool = false
export var high_score_run_completed : bool = false

# Additional persistent game flags
export var first_time_playing : bool = true
export var all_dogs_collected : bool = false

func _init():
	print("date time is ", Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(true), false))
	save_created_at =  Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(true), false)
	save_version = 1
