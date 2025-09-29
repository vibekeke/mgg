extends Control

export (PackedScene) var root_scene

onready var star_select_start = get_node("%StarSelectStart")
onready var star_select_quit = get_node("%StarSelectQuit")
onready var star_select_credits = get_node("%StarSelectCredits")
onready var star_select_room = get_node("%StarSelectRoom")
onready var star_select_fullscreen = get_node("%StarSelectFullscreen")

onready var winner_crown = get_node("%WinnerCrown")

onready var title_screen_animation = get_node("%TitleScreenAnimation")
onready var camera = get_node("%Camera2D")
onready var tween = get_node("%Tween")

onready var start_button : Button = get_node("%StartButton")
onready var room_button : Button = get_node("%RoomButton")
onready var credits_button : Button = get_node("%CreditsButton")
onready var quit_button : Button = get_node("%QuitButton")
onready var fullscreen_label = get_node("%FullscreenLabel")

onready var credits_menu = get_node("%Credits")
onready var credits_hide_button = get_node("%CreditsHideButton")

onready var delete_save_button = get_node("%DeleteSaveButton")
onready var delete_save_panel = get_node("%DeleteSavePanel")

onready var camera_timer : Timer = Timer.new()
onready var high_score : int = SaveFileManager.get_high_score()

onready var cheat_code_detection : PoolStringArray = PoolStringArray()
var successful_cheat_code : String = "00112323"
var cheat_code_activated : bool = false

var has_completed_demo : bool = false
var button_pressed : bool = false
var first_focus : bool = true

func _ready():
	Events.initialize()

	cheat_code_detection = []

	# Setup camera timer
	add_child(camera_timer)
	camera_timer.wait_time = 0.5
	camera_timer.one_shot = true
	camera_timer.connect("timeout", self, "_start_camera_tween")

	start_camera_sequence()
	SceneManager.visible = true
	var directory = Directory.new()
	var fileExists = directory.file_exists(Events.SAVE_FILE_LOCATION)
	print("MainMenu: Events dogs complete = ", Events.dogs_complete)
	if !Events.dogs_complete:
		room_button.text = "???"
		room_button.disabled = true
	else:
		room_button.text = "Bedroom"
		room_button.disabled = false
	AudioManager.play_music("main_menu")
	credits_menu.visible = false
	title_screen_animation.connect("animation_finished", self, "_on_characters_appear_finished")
	title_screen_animation.play("characters_appear")

func _on_characters_appear_finished(anim_name):
	var real_gamer : bool = SaveFileManager.get_beaten_first_level_before() and SaveFileManager.get_all_dogs_collected()
	if real_gamer:
		winner_crown.visible = true

func _process(delta):
	if (title_screen_animation.is_playing() or tween.is_active() or !camera_timer.is_stopped()) and Input.is_action_just_pressed("ui_accept"):
		tween.playback_speed = 10
		title_screen_animation.playback_speed = 10
		# Speed up camera timer by reducing wait time significantly
		if !camera_timer.is_stopped():
			camera_timer.wait_time = 0.1

func _on_StartButton_pressed():
	if !button_pressed:
		button_pressed = true
		AudioManager.playSFX("ui_confirm", 1.0, 5.0)
		AudioManager.fade_out_music(1)
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
	pass

func _on_TitleScreenAnimation_animation_finished(anim_name):
	if anim_name == "characters_appear":
		$MenuLayer/VBoxContainer/StartButton.grab_focus()

func _on_RoomButton_pressed():
	AudioManager.fade_out_music(1.0)
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

func _on_CreditsButton_pressed():
	AudioManager.playSFX("ui_confirm")
	credits_menu.visible = true
	credits_hide_button.grab_focus()

func _on_CreditsButton_focus_entered():
	AudioManager.playSFX("ui_hover")
	star_select_credits.visible = true

func _on_CreditsButton_focus_exited():
	star_select_credits.visible = false

func _on_CreditsButton_mouse_entered():
	credits_button.grab_focus()

func _on_CreditsHideButton_pressed():
	credits_menu.visible = false
	delete_save_panel.visible = false
	credits_button.grab_focus()

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

func play_sound(sound_key : String, volume : float):
	AudioManager.playSFX(sound_key, 1.0, volume)

func _on_FullscreenCheckbox_toggled(button_pressed):
	if button_pressed:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false

## Delete Save
func _on_DeleteSaveButton_pressed():
	if delete_save_panel.visible:
		delete_save_panel.visible = false
	else:
		delete_save_panel.visible = true
	
	$"%AreYouSureLabel".text = "Are you want to delete your save? \nThis action cannot be undone."
	$"%YesDeleteButton".show()
	$"%NoDeleteButton".show()

func _on_YesDeleteButton_pressed():
	SaveFileManager.reset_save_file()
	AudioManager.playSFX("player_damage")
	$"%AreYouSureLabel".text ="\nSave Data Deleted."
	$"%YesDeleteButton".hide()
	$"%NoDeleteButton".hide()
	yield(get_tree().create_timer(2.0), "timeout")
	room_button.text = "???"
	room_button.disabled = true
	delete_save_panel.visible = false

func _on_NoDeleteButton_pressed():
	delete_save_panel.visible = false

func _on_YesDeleteButton_focus_entered():
	SaveFileManager.reset_save_file()
	AudioManager.playSFX("ui_hover", 1.0, -5.0)

func _on_NoDeleteButton_focus_entered():
	AudioManager.playSFX("ui_hover")

func _on_FullscreenCheckbox_focus_entered():
	AudioManager.playSFX("ui_hover")
	star_select_fullscreen.visible = true
	fullscreen_label.modulate = Color(1, 0.87, 0.73, 1)
	
func _on_FullscreenCheckbox_focus_exited():
	star_select_fullscreen.visible = false
	fullscreen_label.modulate = Color(1, 1, 1, 1)

func start_camera_sequence():
	camera_timer.start()

func _start_camera_tween():
	tween.interpolate_property(camera, "position",
		camera.position, Vector2(961, 540), 4,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

