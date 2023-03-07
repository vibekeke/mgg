extends Control

export (PackedScene) var root_scene

onready var resolution_list = $CanvasLayer/OptionsMenu/HBoxContainer/ResolutionList

func _ready():
	var scene_manager = get_node_or_null("%SceneManager")
	if scene_manager != null:
		scene_manager.visible = true
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionButton.connect("pressed", self, "_on_ResolutionButton_pressed")
	$CanvasLayer/VBoxContainer/StartButton.grab_focus()
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionList.connect("item_activated", self, "_on_ResolutionList_item_activated")
	var directory = Directory.new()
	var fileExists = directory.file_exists(Events.SAVE_FILE_LOCATION)
	if fileExists:
		$CanvasLayer/VBoxContainer/LoadButton.visible = true

func _on_StartButton_pressed():
	Events.emit_signal("transition_to_scene", "TutorialSelection")
	$AudioStreamPlayer.play(0.0)

func _on_OptionsButton_pressed():
	$CanvasLayer/VBoxContainer.visible = false
	$CanvasLayer/OptionsMenu.visible = true
	$CanvasLayer/OptionsMenu/HBoxContainer/ResolutionList.grab_focus()

func _on_BackButton_pressed():
	$CanvasLayer/OptionsMenu.visible = false
	$CanvasLayer/VBoxContainer.visible = true
	$CanvasLayer/VBoxContainer/StartButton.grab_focus()

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
			Events.emit_signal("transition_to_scene", "ComputerScreen")
		2:
			Events.emit_signal("transition_to_scene", "ComputerScreen")
		3:
			Events.emit_signal("transition_to_scene", "ComputerScreen")

func _on_LoadButton_pressed():
	$AudioStreamPlayer.play(0.0)
	Events.load_game()
	var last_completed_level = Events.COMPLETED_LEVELS[Events.COMPLETED_LEVELS.size() - 1]
	send_to_computer(last_completed_level)
