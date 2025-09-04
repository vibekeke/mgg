extends Control

export (PackedScene) var root_scene

onready var star_select_start = get_node("%StarSelectStart")
onready var star_select_quit = get_node("%StarSelectQuit")
onready var star_select_room = get_node("%StarSelectRoom")
onready var title_screen_animation = get_node("%TitleScreenAnimation")
onready var all_dogs_completion_message = get_node("%AllDogsCompletion")
onready var camera = get_node("%Camera2D")
onready var tween = get_node("%Tween")

onready var start_button : Button = get_node("%StartButton")
onready var room_button : Button = get_node("%RoomButton")
onready var quit_button : Button = get_node("%QuitButton")

onready var cheat_code_detection : PoolStringArray = PoolStringArray()
var successful_cheat_code : String = "00112323"
var cheat_code_activated : bool = false

var has_completed_demo : bool = false
var button_pressed : bool = false
var first_focus : bool = true

var all_dogs_collected : bool = false

func _ready():
	cheat_code_detection = []
	all_dogs_completion_message.connect("all_dogs_message_finished", self, "_on_all_dogs_finished_message")
	all_dogs_collected = Events.COLLECTED_DOGS.size() >= 3
	if all_dogs_collected:
		all_dogs_collected_message_display()
	tween.interpolate_property(camera, "position",
		camera.position, Vector2(961, 540), 2,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	SceneManager.visible = true
	var directory = Directory.new()
	var fileExists = directory.file_exists(Events.SAVE_FILE_LOCATION)
	if !all_dogs_collected:
		room_button.text = "???"
		room_button.disabled = true
	else:
		room_button.text = "Bedroom"
		room_button.disabled = false
	AudioManager.playSFX("twinkle")
	

func all_dogs_collected_message_display():
	all_dogs_completion_message.display_message()

func _process(delta):
	if (title_screen_animation.is_playing() or tween.is_active()) and Input.is_action_just_pressed("ui_accept"):
		tween.playback_speed = 10
		title_screen_animation.playback_speed = 10

func _on_StartButton_pressed():
	if !button_pressed:
		button_pressed = true
		AudioManager.playSFX("ui_confirm", 0.0, 5.0)
		send_to_level("Level1")

func _on_OptionsButton_pressed():
	$MenuLayer/VBoxContainer.visible = false

func _on_BackButton_pressed():
	$MenuLayer/VBoxContainer.visible = true
	$MenuLayer/VBoxContainer/StartButton.grab_focus()

func _on_QuitButton_pressed():
	get_tree().quit()

func send_to_level(level_name: String):
	Events.emit_signal("transition_to_scene", level_name, false)

func _on_StartButton_focus_entered():
	if first_focus:
		first_focus = false
	else:	
		AudioManager.playSFX("ui_hover")
	star_select_start.visible = true

func _on_StartButton_focus_exited():
	star_select_start.visible = false

func _on_QuitButton_focus_entered():
	AudioManager.playSFX("ui_hover")
	star_select_quit.visible = true

func _on_QuitButton_focus_exited():
	star_select_quit.visible = false

func _on_Tween_tween_all_completed():
	title_screen_animation.play("characters_appear")

func _on_TitleScreenAnimation_animation_finished(anim_name):
	if anim_name == "characters_appear":
		$MenuLayer/VBoxContainer/StartButton.grab_focus()

func _on_RoomButton_pressed():
	send_to_level("Bedroom")

func _on_RoomButton_focus_entered():
	AudioManager.playSFX("ui_hover")
	star_select_room.visible = true

func _on_RoomButton_focus_exited():
	star_select_room.visible = false

func _on_QuitButton_mouse_entered():
	quit_button.grab_focus()

func _on_RoomButton_mouse_entered():
	if not room_button.disabled:
		room_button.grab_focus()

func _on_StartButton_mouse_entered():
	start_button.grab_focus()

func activate_cheat_code():
	if not cheat_code_activated:
		cheat_code_activated = true
		room_button.text = "Bedroom"
		room_button.disabled = false

func _input(event):
	var input_code = ""
	
	if event.is_action_pressed("ui_up"):
		input_code = "0"
	elif event.is_action_pressed("ui_down"):
		input_code = "1"
	elif event.is_action_pressed("ui_left"):
		input_code = "2"
	elif event.is_action_pressed("ui_right"):
		input_code = "3"
	
	if input_code != "":
		cheat_code_detection.append(input_code)
		
		if cheat_code_detection.size() > 8:
			cheat_code_detection.remove(0)
		
		if cheat_code_detection.join("") == successful_cheat_code:
			activate_cheat_code()


func play_sound(sound_key : String):
	AudioManager.playSFX(sound_key)
	
