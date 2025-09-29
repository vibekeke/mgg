extends Node

const SAVE_FILE_PATH = "user://savefile.dat"
const BACKUP_SAVE_PATH = "user://savefile_backup.dat"
const TEMP_SAVE_PATH = "user://savefile_temp.dat"

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
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file != null:
			var data = file.get_var(false) # false = no objects, secure
			file.close()

			if data != null and typeof(data) == TYPE_DICTIONARY:
				current_save_file = SaveFile.new()
				if current_save_file.from_dict(data):
					print("Save file loaded successfully!")
					print_save_file_contents()
					return
				else:
					print("Save file data invalid, trying backup...")
			else:
				print("Save file corrupted, trying backup...")
		else:
			print("Failed to open save file, trying backup...")

		if try_load_backup():
			return
		else:
			print("Backup failed too, creating new one")
			create_new_save_file()
	else:
		print("No save file found, creating new one")
		create_new_save_file()

func try_load_backup() -> bool:
	if FileAccess.file_exists(BACKUP_SAVE_PATH):
		var file = FileAccess.open(BACKUP_SAVE_PATH, FileAccess.READ)
		if file != null:
			var data = file.get_var(false) # false = no objects, secure
			file.close()

			if data != null and typeof(data) == TYPE_DICTIONARY:
				current_save_file = SaveFile.new()
				if current_save_file.from_dict(data):
					print("Backup save file loaded successfully!")
					print_save_file_contents()
					# Restore main save from backup
					save_to_disk()
					return true
	return false

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
	#print("Created new save file with initial values:")
	#print_save_file_contents()
	save_to_disk()

func save_to_disk():
	# Atomic save: write to temp file first, then move to main location
	var file = FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open temp file for writing")
		return

	file.store_var(current_save_file.to_dict(), false) # false = no objects, secure
	file.close()

	# Create backup from current save file before overwriting
	var dir = DirAccess.open("user://")
	if dir != null and dir.file_exists(SAVE_FILE_PATH):
		if dir.copy(SAVE_FILE_PATH, BACKUP_SAVE_PATH) != OK:
			print("Warning: Failed to create backup")

	# Move temp file to main location
	if dir == null or dir.rename(TEMP_SAVE_PATH, SAVE_FILE_PATH) != OK:
		print("Failed to move temp file to main save location")
		return

	print("Save file saved successfully")

# Getters for save data
func get_high_score() -> int:
	return current_save_file.high_score

func get_beaten_first_level_before() -> bool:
	return current_save_file.has_beaten_first_stage_before
	
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
func set_high_score(value: int):
	current_save_file.high_score = value
	save_to_disk()

func set_beaten_first_level_before(value: bool):
	current_save_file.has_beaten_first_stage_before = value
	save_to_disk()

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

func delete_all_save_files():
	var dir = DirAccess.open("user://")
	if dir == null:
		print("Failed to access user directory")
		return

	# Delete main save file
	if dir.file_exists(SAVE_FILE_PATH):
		if dir.remove(SAVE_FILE_PATH) != OK:
			print("Warning: Failed to delete save file")

	# Delete backup save file
	if dir.file_exists(BACKUP_SAVE_PATH):
		if dir.remove(BACKUP_SAVE_PATH) != OK:
			print("Warning: Failed to delete backup save file")

	# Delete temp file if it exists
	if dir.file_exists(TEMP_SAVE_PATH):
		if dir.remove(TEMP_SAVE_PATH) != OK:
			print("Warning: Failed to delete temp save file")

	print("All save files deleted")

func reset_save_file():
	delete_all_save_files()
	create_new_save_file()
	sync_to_stats_tracker()
	Events.first_time_playing = true
	Events.dogs_complete = false
	print("Save file reset to defaults")
