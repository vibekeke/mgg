extends CanvasLayer

signal actioned(next_id)
onready var dialogue_label = get_node("%DialogueLabel")
onready var dialogue_container = get_node("%DialogueContainer")
onready var responses_list = get_node("%ResponsesList")
onready var portrait = get_node("%Portrait")
onready var character_title = get_node("%CharacterTitle")
onready var await_cursor = get_node("%AwaitCursor")

var dialogue
var is_waiting_for_input: bool = false
var is_processing_response: bool = false
var inputs_are_disabled: bool = false


func set_dialogue(dialogue):
	self.dialogue = dialogue

func set_next_dialogue(dialogue):
	self.dialogue = dialogue
	add_dialogue()

func add_dialogue():
	await_cursor.visible = false
	inputs_are_disabled = true
	if not dialogue:
		inputs_are_disabled = false
		self.queue_free()
		return

	self.dialogue = dialogue
	if dialogue.character == "":
		portrait.hide()
		character_title.hide()
	else:
		portrait.show()
		character_title.bbcode_text = dialogue.character

		dialogue_label.rect_size.x = dialogue_label.get_parent().rect_size.x
	dialogue_label.dialogue_line = dialogue

#	if dialogue.responses.size() > 0:
#		for response in dialogue.responses:
#			var response_item = preload("res://TestShit/ResponseTemplate.tscn").instance()
#			response_item.name = "Response" + str(responses_list.get_child_count())
#			if not response.is_allowed:
#				response_item.name += "Disallowed"
#			response_item.set_text(response.text)
#			response_item.connect("gui_input", self, "_on_response_gui_input", [response_item])
#			response_item.show()
#			responses_list.add_child(response_item)

	dialogue_label.type_out()
	yield(dialogue_label, "finished")
	await_cursor.visible = true
	if dialogue.responses.size() > 0:
		# show responses if they exist
		is_processing_response = true
		for response in dialogue.responses:
			var response_item = preload("res://TestShit/ResponseTemplate.tscn").instance()
			response_item.name = "Response" + str(responses_list.get_child_count())
			if not response.is_allowed:
				response_item.name += "Disallowed"
			response_item.connect("gui_input", self, "_on_response_gui_input", [response_item])
			response_item.show()
			responses_list.add_child(response_item)
			response_item.set_text(response.text)
		is_processing_response = false
		responses_list.visible = true
		configure_focus()
	elif dialogue.time != null:
		var time = dialogue.dialogue.length() * 0.02 if dialogue.time == "auto" else dialogue.time.to_float()
		yield(get_tree().create_timer(time), "timeout")
		next(dialogue.next_id)
	else:
		is_waiting_for_input = true
		# some stuff to do with focus i don't get yet
		dialogue_container.focus_mode = Control.FOCUS_ALL
		dialogue_container.grab_focus()
	
	inputs_are_disabled = false


func _ready() -> void:
	add_dialogue()

func next(next_id: String) -> void:
	if inputs_are_disabled:
		return
	emit_signal("actioned", next_id)

func configure_focus() -> void:
	responses_list.show()
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]

		item.focus_mode = Control.FOCUS_ALL
		item.focus_neighbour_top = item.get_path()
		item.focus_neighbour_bottom = item.get_path()

		if i == 0:
			item.focus_neighbour_left = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbour_left = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbour_right = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbour_right = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
	
	
	items[0].grab_focus()

func get_responses() -> Array:
	var items: Array = []
	for child in responses_list.get_children():
		items.append(child)
	return items

func destroy_responses() -> void:
	for child in responses_list.get_children():
		child.queue_free()

func _on_response_gui_input(event, item):
	if event.is_pressed() and not event.is_echo() and item in get_responses():
		if Input.is_action_just_pressed("ui_accept"):
			destroy_responses()
			next(dialogue.responses[item.get_index()].next_id)

func _on_DialogueContainer_gui_input(event):
	if event.is_pressed() and not event.is_echo() and dialogue_container.get_focus_owner() == dialogue_container:
		if Input.is_action_just_pressed("ui_accept"):
			next(dialogue.next_id)
