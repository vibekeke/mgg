extends Control

onready var chat_app = get_node("%ChatApp")
onready var chatLog = get_node("VBoxContainer/RichTextLabel")
onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{'name': 'Team', 'color': '#00abc7'},
	{'name': 'Match', 'color': '#ffdd8b'},
	{'name': 'Global', 'color': '#ffffff'}
]
var group_index = 0
var user_name = 'Player'
var script_place = 0

var conversationScript = [
	{ 'name': 'MGG', 'color': '#000000', 'script': 'Hello :D\n', 'delay': 1000 },
	{ 'name': 'Not an alien', 'color': '#000000', 'script': 'Hello there fellow human.\n', 'delay': 1000 },
	{ 'name': 'MGG', 'color': '#000000', 'script': 'I\'ll kill ya :)\n', 'delay': 1000 }
]

func _ready():
	inputField.connect("text_entered", self,'text_entered')
	change_group(0)

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			if script_place >= conversationScript.size():
				print("Convo finished")
			else:
				var dialog_line = conversationScript[script_place]['script']
				var char_name = conversationScript[script_place]['name']
				var char_color = conversationScript[script_place]['color']
				var delay_ms = 0
				if conversationScript[script_place]['delay']:
					delay_ms = conversationScript[script_place]['delay']
				var delay_timer = Timer.new()
				delay_timer.set_wait_time(float(delay_ms) / 1000.0)
				add_child(delay_timer)
				delay_timer.start()
				yield(delay_timer, "timeout")
				message_entered(char_name, dialog_line, char_color)
				script_place += 1
				
func message_entered(char_name, text, color):
	add_message(char_name, text, 0, color)
	inputField.text = ''

func change_group(value):
	group_index += value
	if group_index > (groups.size() - 1):
		group_index = 0
	inputLabel.text = '[' + groups[group_index]['name'] + ']'
	inputLabel.set("custom_colors/font_color", Color(groups[group_index]['color']))
	
func add_message(username, text, group = 0, color = ''):
	chatLog.bbcode_text += '\n' 
	if color == '':
		chatLog.bbcode_text += '[color=' + groups[group]['color'] + ']'
	else:
		chatLog.bbcode_text += '[color=' + color + ']'
	if username != '':
		chatLog.bbcode_text += '[' + username + ']: '
	chatLog.bbcode_text += text
	chatLog.bbcode_text += '[/color]'


func text_entered(text):
	if text =='/h':
		add_message('', 'There is no help message yet!', 0, '#ff5757')
		inputField.text = ''		
		return
	if text != '':
		add_message(user_name, text, group_index)
		# Here you have to send the message to the server
		print(text)
		inputField.text = ''
