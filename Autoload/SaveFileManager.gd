extends Node

const SAVE_FILE_PATH = "user://savefile.res"

var current_save_file : SaveFile
var is_initialized : bool = false

func _ready():
	initialize()

func initialize():
	if is_initialized:
		return
	load_save_file()
	is_initialized = true
	print("SaveFileManager: Initialized")

func load_save_file():
	if ResourceLoader.exists(SAVE_FILE_PATH):
		current_save_file = ResourceLoader.load(SAVE_FILE_PATH)
		if current_save_file == null:
			print("Failed to load save file, creating new one")
			create_new_save_file()
		else:
			print("Save file loaded successfully!")
			print_save_file_contents()
	else:
		print("No save file found, creating new one")
		create_new_save_file()

func print_save_file_contents():
	print("=== SAVE FILE CONTENTS ===")
	print("Save created at: ", current_save_file.save_created_at)
	print("Save version: ", current_save_file.save_version)
	print("First time playing: ", current_save_file.first_time_playing)
	print("All dogs collected: ", current_save_file.all_dogs_collected)
	print("No float run completed: ", current_save_file.no_float_run_completed)
	print("No damage taken run completed: ", current_save_file.no_damage_taken_run_completed)
	print("Pacifist run completed: ", current_save_file.pacifist_run_completed)
	print("High score run completed: ", current_save_file.high_score_run_completed)
	print("==========================")

func create_new_save_file():
	current_save_file = SaveFile.new()
	print("Created new save file with initial values:")
	print_save_file_contents()
	save_to_disk()

func save_to_disk():
	var error = ResourceSaver.save(SAVE_FILE_PATH, current_save_file)
	if error != OK:
		print("Failed to save file: ", error)
	else:
		print("Save file saved successfully")

# Getters for save data
func get_no_float_run_completed() -> bool:
	return current_save_file.no_float_run_completed

func get_no_damage_taken_run_completed() -> bool:
	return current_save_file.no_damage_taken_run_completed

func get_pacifist_run_completed() -> bool:
	return current_save_file.pacifist_run_completed

func get_high_score_run_completed() -> bool:
	return current_save_file.high_score_run_completed

func get_first_time_playing() -> bool:
	return current_save_file.first_time_playing



func get_all_dogs_collected() -> bool:
	return current_save_file.all_dogs_collected

# Setters for save data
func set_no_float_run_completed(value: bool):
	current_save_file.no_float_run_completed = value
	save_to_disk()

func set_no_damage_taken_run_completed(value: bool):
	current_save_file.no_damage_taken_run_completed = value
	save_to_disk()

func set_pacifist_run_completed(value: bool):
	current_save_file.pacifist_run_completed = value
	save_to_disk()

func set_high_score_run_completed(value: bool):
	current_save_file.high_score_run_completed = value
	save_to_disk()

func set_first_time_playing(value: bool):
	current_save_file.first_time_playing = value
	save_to_disk()

func set_all_dogs_collected(value: bool):
	current_save_file.all_dogs_collected = value
	save_to_disk()

func sync_from_stats_tracker():
	current_save_file.no_float_run_completed = StatsTracker.no_float_run_completed
	current_save_file.no_damage_taken_run_completed = StatsTracker.no_damage_taken_run_completed
	current_save_file.pacifist_run_completed = StatsTracker.pacifist_run_completed
	current_save_file.high_score_run_completed = StatsTracker.high_score_run_completed
	save_to_disk()

func sync_to_stats_tracker():
	StatsTracker.no_float_run_completed = current_save_file.no_float_run_completed
	StatsTracker.no_damage_taken_run_completed = current_save_file.no_damage_taken_run_completed
	StatsTracker.pacifist_run_completed = current_save_file.pacifist_run_completed
	StatsTracker.high_score_run_completed = current_save_file.high_score_run_completed
