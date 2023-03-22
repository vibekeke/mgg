extends WindowDialog

onready var parent_node = self.get_parent()
var PLAYER_IDENTIFIER = "MGG"
var conversation_path = "res://Conversations/"
onready var current_dialog = ""
onready var receiver_name = ""
onready var sender_name = ""
onready var current_dialog_entry_number = 0
onready var script_array = give_current_script()
onready var script_entries = script_array.size()
onready var chat_sender_box = get_node("%ChatTextSender")
onready var chat_box = get_node("%ChatBox")
onready var chat_send_button = get_node("%SendMessageButton")

onready var typing_sounds = [get_node("%TypingSound") , get_node("%TypingSound2"), get_node("%TypingSound3")]
onready var current_typing_sound = 0

onready var _type_timer = Timer.new()
onready var _counterpart_is_typing_timer = Timer.new()

func _ready():
	randomize()
	
	_type_timer.set_wait_time(.01)
	_type_timer.set_one_shot(true)
	self.add_child(_type_timer)
	
	_counterpart_is_typing_timer.set_wait_time(5.0)
	_counterpart_is_typing_timer.set_one_shot(true)
	self.add_child(_counterpart_is_typing_timer)
	
	typing_sounds.shuffle()

func give_current_script():
	var loaded_dialog = File.new()
	if not loaded_dialog.file_exists("res://Conversations/intro/intro-convo-1.json"):
		print_debug("Conversation not found.")
		return
	loaded_dialog.open("res://Conversations/intro/intro-convo-1.json", File.READ)
	var dialog_data = JSON.parse(loaded_dialog.get_as_text())
	if typeof(dialog_data.result) == TYPE_ARRAY:
		return dialog_data.result
	print_debug("Failed to read dialog data!")
	return []

func type_then_send(text_to_type, sender):
	var typing_sound = typing_sounds[current_typing_sound]
	typing_sound.play()
	for character in text_to_type:
		_type_timer.start()
		chat_sender_box.text += character
		yield(_type_timer, "timeout")
	typing_sound.stop()
	current_typing_sound += 1
	if current_typing_sound >= typing_sounds.size() - 1:
		current_typing_sound = 0
	if sender == PLAYER_IDENTIFIER:
		chat_sender_box.text = ""
		chat_box.create_player_panel(text_to_type)
		check_counterpart_typing()
	else:
		chat_box.create_counterpart_panel(text_to_type)
		
func check_counterpart_typing():
	if script_array.size() <= current_dialog_entry_number:
		print("no counterpart, dialog is finished")
		return
	if script_array[current_dialog_entry_number]['name'] != PLAYER_IDENTIFIER:
		var text_to_type = script_array[current_dialog_entry_number]['script']
		chat_box.display_is_typing(script_array[current_dialog_entry_number]['name'])
		_counterpart_is_typing_timer.start()
		yield(_counterpart_is_typing_timer, "timeout")
		chat_box.hide_is_typing()
		chat_box.create_counterpart_panel(text_to_type)
		current_dialog_entry_number = current_dialog_entry_number + 1
		chat_send_button.disabled = false

func _on_ChatApp_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if parent_node != null:
				parent_node.move_child(self, parent_node.get_child_count())
			else:
				print_debug("That did not work dummy")

func _on_SendMessageButton_button_up():
	chat_send_button.disabled = true
	if current_dialog_entry_number == script_entries:
		print("finished reading script")
		return
	var current_script_entry = script_array[current_dialog_entry_number]
	print("current script entry is ", current_script_entry)
	if current_script_entry['name'] == PLAYER_IDENTIFIER:
		type_then_send(current_script_entry['script'], PLAYER_IDENTIFIER)
		chat_send_button.disabled = true
	else:
		chat_send_button.disabled = false
	current_dialog_entry_number = current_dialog_entry_number + 1
