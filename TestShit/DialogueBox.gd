extends Control


signal actioned(next_id)


const DialogueLine = preload("res://addons/dialogue_manager/dialogue_line.gd")


#export(NodePath) onready var response_template = get_node(response_template)

onready var balloon := get_node("%PanelContainer")
onready var margin := get_node("%MarginContainer")
onready var character_label := get_node("%CharacterName")
#onready var character_portrait := get_node("%CharacterSprite")
onready var dialogue_label := get_node("%DialogueLabel")
#onready var responses_menu := get_node("%Responses")


var dialogue
var is_waiting_for_input: bool = false


func set_dialogue(dialogue):
	self.dialogue = dialogue

func _ready() -> void:
	if not dialogue:
		pass
		print("No dialogue!")
		queue_free()
		return
	
	#response_template.hide()
	print("yes dialogue")
	balloon.hide()
	
	#var viewport_size = balloon.get_viewport_rect().size
	#margin.rect_size.x = viewport_size.x * 0.9
	
	if dialogue.character != "":
		character_label.visible = true
		character_label.bbcode_text = dialogue.character
		#character_portrait.texture = load("res://DialogBox/portraits_balloon/portraits/%s.png" % dialogue.character)
	else:
		character_label.visible = false
	
	#dialogue_label.rect_size.x = dialogue_label.get_parent().rect_size.x
	dialogue_label.dialogue_line = dialogue
	yield(dialogue_label.reset_height(), "completed")
	
	# Show any responses we have
#	if dialogue.responses.size() > 0:
#		for response in dialogue.responses:
#			# Duplicate the template so we can grab the fonts, sizing, etc
#			var item: RichTextLabel = response_template.duplicate(0)
#			item.name = "Response" + str(responses_menu.get_child_count())
#			if not response.is_allowed:
#				item.name += "Disallowed"
#			item.bbcode_text = response.text
#			item.connect("mouse_entered", self, "_on_response_mouse_entered", [item])
#			item.connect("gui_input", self, "_on_response_gui_input", [item])
#			item.show()
#			responses_menu.add_child(item)
	
	# Make sure our responses get included in the height reset
#	responses_menu.visible = true
	#margin.rect_size = Vector2(0, 0)
	
	yield(get_tree(), "idle_frame")
	
	#balloon.rect_min_size = margin.rect_size
	#balloon.rect_size = Vector2(0, 0)
	#balloon.rect_global_position = Vector2((viewport_size.x - balloon.rect_size.x) * 0.5, viewport_size.y - balloon.rect_size.y)
	
	# Ok, we can hide it now. It will come back later if we have any responses
#	responses_menu.visible = false
	
	# Show our box
	balloon.visible = true
	
	dialogue_label.type_out()
	yield(dialogue_label, "finished")
	
	# Wait for input
	if dialogue.responses.size() > 0:
#		responses_menu.visible = true
		configure_focus()
	elif dialogue.time != null:
		var time = dialogue.dialogue.length() * 0.02 if dialogue.time == "auto" else dialogue.time.to_float()
		yield(get_tree().create_timer(time), "timeout")
		next(dialogue.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()
		

func next(next_id: String) -> void:
	emit_signal("actioned", next_id)
	queue_free()


### Helpers


func configure_focus() -> void:
#	responses_menu.show()
	
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbour_left = item.get_path()
		item.focus_neighbour_right = item.get_path()
		
		if i == 0:
			item.focus_neighbour_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbour_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbour_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbour_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
	
	items[0].grab_focus()


func get_responses() -> Array:
	var items: Array = []
#	for child in responses_menu.get_children():
#		if "disallowed" in child.name.to_lower(): continue
#		items.append(child)
		
	return items


### Signals


func _on_response_mouse_entered(item):
	item.grab_focus()


func _on_response_gui_input(event, item):
	if event is InputEventMouseButton and event.is_pressed():
		next(dialogue.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		next(dialogue.responses[item.get_index()].next_id)


# When there are no response options the balloon itself is the clickable thing
func _on_Balloon_gui_input(event):
	if not is_waiting_for_input: return
	
	get_tree().set_input_as_handled()
	
	if event is InputEventMouseButton and event.is_pressed():
		next(dialogue.next_id)
	elif event.is_action_pressed("ui_accept") and balloon.get_focus_owner() == balloon:
		next(dialogue.next_id)
