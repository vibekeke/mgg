extends Control

export (PackedScene) var root_scene

onready var resolution_list = $MenuLayer/OptionsMenu/HBoxContainer/ResolutionList
onready var star_select_start = get_node("%StarSelectStart")
onready var star_select_load = get_node("%StarSelectLoad")
onready var star_select_options = get_node("%StarSelectOptions")
onready var star_select_quit = get_node("%StarSelectQuit")
onready var title_screen_animation = get_node("%TitleScreenAnimation")
onready var camera = get_node("%Camera2D")
onready var tween = get_node("%Tween")
onready var scene_manager = get_node("%SceneManager")

func _ready():
	tween.interpolate_property(camera, "position",
		camera.position, Vector2(961, 540), 2,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	scene_manager.visible = true
	$MenuLayer/OptionsMenu/HBoxContainer/ResolutionButton.connect("pressed", self, "_on_ResolutionButton_pressed")
	$MenuLayer/OptionsMenu/HBoxContainer/ResolutionList.connect("item_activated", self, "_on_ResolutionList_item_activated")
	var directory = Directory.new()
	var fileExists = directory.file_exists(Events.SAVE_FILE_LOCATION)
	if fileExists:
		$MenuLayer/VBoxContainer/LoadButton.visible = true

func _process(delta):
	if (title_screen_animation.is_playing() or tween.is_active()) and Input.is_action_just_pressed("ui_accept"):
		tween.playback_speed = 10
		title_screen_animation.playback_speed = 10

func _on_StartButton_pressed():
	Events.emit_signal("transition_to_scene", "TutorialSelection")
	$AudioStreamPlayer.play(0.0)

func _on_OptionsButton_pressed():
	$MenuLayer/VBoxContainer.visible = false
	$MenuLayer/OptionsMenu.visible = true
	$MenuLayer/OptionsMenu/HBoxContainer/ResolutionList.grab_focus()

func _on_BackButton_pressed():
	$MenuLayer/OptionsMenu.visible = false
	$MenuLayer/VBoxContainer.visible = true
	$MenuLayer/VBoxContainer/StartButton.grab_focus()

func _on_ResolutionList_item_activated(index: int):
	match index:
		0:
			if OS.get_window_size() != Vector2(1920, 1080):
				OS.set_window_size(Vector2(1920, 1080))
		1:
			if OS.get_window_size() != Vector2(1280, 720):
				OS.set_window_size(Vector2(1280, 720))
		2:
			var os_screen_res = OS.get_screen_size()
			OS.set_window_size(os_screen_res)
			OS.window_fullscreen = !OS.window_fullscreen
		3:
			_on_BackButton_pressed()
		_:
			print("do nothing")
			
func _on_QuitButton_pressed():
	get_tree().quit()

func send_to_computer(last_completed_level: int):
	match last_completed_level:
		0:
			Events.emit_signal("transition_to_scene", "TutorialSelection")
		1:
			Events.emit_signal("transition_to_scene", "Bedroom")
		2:
			Events.emit_signal("transition_to_scene", "Bedroom")
		3:
			Events.emit_signal("transition_to_scene", "Bedroom")

func _on_LoadButton_pressed():
	$AudioStreamPlayer.play(0.0)
	Events.load_game()
	var last_completed_level = Events.COMPLETED_LEVELS[Events.COMPLETED_LEVELS.size() - 1]
	send_to_computer(last_completed_level)


func _on_StartButton_focus_entered():
	star_select_start.visible = true


func _on_StartButton_focus_exited():
	star_select_start.visible = false


func _on_LoadButton_focus_entered():
	star_select_load.visible = true


func _on_LoadButton_focus_exited():
	star_select_load.visible = false

func _on_OptionsButton_focus_entered():
	star_select_options.visible = true

func _on_OptionsButton_focus_exited():
	star_select_options.visible = false


func _on_QuitButton_focus_entered():
	star_select_quit.visible = true


func _on_QuitButton_focus_exited():
	star_select_quit.visible = false


func _on_Tween_tween_all_completed():
	title_screen_animation.play("characters_appear")


func _on_TitleScreenAnimation_animation_finished(anim_name):
	if anim_name == "characters_appear":
		$MenuLayer/VBoxContainer/StartButton.grab_focus()
