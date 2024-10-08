extends CanvasLayer

signal actioned(next_id)
onready var dialogue_main_window = get_node("%DialogueBackground")
onready var dialogue_label = get_node("%DialogueLabel")
onready var dialogue_container = get_node("%DialogueContainer")
onready var responses_list = get_node("%ResponsesList")
onready var portrait = get_node("%Portrait")
onready var character_title = get_node("%CharacterTitle")
onready var await_cursor = get_node("%AwaitCursor")
onready var dialogue_audio = get_node("%DialogueAudio")
onready var star_flicker_animation_player = get_node("%StarFlickerAnimationPlayer")
onready var margin_container = get_node("%MarginContainer")

var placement_dictionary = {
	DataClasses.Placement.LOWER: {'dialogue_main_window': {'top': 0.7, 'bottom': 0.95}, 'portrait': {'top': 0.6, 'bottom': 0.6}, 'cursor': {'position': Vector2(1396.0, 981.0)}},
	DataClasses.Placement.MIDDLE: {'dialogue_main_window': {'top': 0.7, 'bottom': 0.95}, 'portrait': {'top': 0.6, 'bottom': 0.6}, 'cursor': {'position': Vector2(0.0,0.0)}},
	DataClasses.Placement.UPPER: {'dialogue_main_window': {'top': 0.05, 'bottom': 0.3}, 'portrait': {'top': 0.0, 'bottom': 0.0}, 'cursor': {'position': Vector2(1396.0, 290.0)}}
}

var placement = DataClasses.Placement.LOWER
var character_portrait = DataClasses.CharacterPortrait.None

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
		margin_container.add_constant_override("margin_right", 10)
		portrait.hide()
		character_title.hide()
	else:
		portrait.show()
		margin_container.add_constant_override("margin_right", 125)
		character_title.bbcode_text = dialogue.character

		dialogue_label.rect_size.x = dialogue_label.get_parent().rect_size.x
	dialogue_label.dialogue_line = dialogue

	dialogue_label.type_out()
	yield(dialogue_label, "finished")
	await_cursor.visible = true
	star_flicker_animation_player.play("flicker")
	if dialogue.responses.size() > 0:
		# show responses if they exist
		is_processing_response = true
		for response in dialogue.responses:
			var response_item = preload("res://DialogBox/ResponseTemplate.tscn").instance()
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


func container_placement():
	dialogue_main_window.anchor_bottom = placement_dictionary[placement]['dialogue_main_window']['bottom']
	dialogue_main_window.anchor_top = placement_dictionary[placement]['dialogue_main_window']['top']

	portrait.anchor_bottom = placement_dictionary[placement]['portrait']['top']
	portrait.anchor_top = placement_dictionary[placement]['portrait']['bottom']

	await_cursor.global_position = placement_dictionary[placement]['cursor']['position']

func set_character_portrait():
	portrait.display_character(character_portrait)

func _ready() -> void:
	set_character_portrait()
	container_placement()
	dialogue_label.connect("arriving_characer", self, "_on_arriving_character")
	add_dialogue()

func _on_arriving_character(character: String):
	if character != "":
		var lower_case_character = character.to_lower()
		if lower_case_character in "aeiou":
			dialogue_audio.play(0.0)

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
