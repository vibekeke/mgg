extends WindowDialog

func give_current_script():
	var loaded_dialog = File.new()
	if not loaded_dialog.file_exists("res://Conversations/intro/intro-convo-1.json"):
		print_debug("Conversation not found.")
		return
	loaded_dialog.open("res://Conversations/intro/intro-convo-1.json", File.READ)
	var dialog_data = JSON.parse(loaded_dialog.get_as_text())
	if typeof(dialog_data.result) == TYPE_ARRAY:
		return dialog_data
	print_debug("Failed to read dialog data!")
	return []
	

func _ready():
	give_current_script()
