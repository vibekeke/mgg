
extends CanvasLayer

@export var fade_duration := 0.5
@export_enum("Level1", "Level2", "Level3", "GameOver", "None") var retry_scene : String

@onready var color_rect : ColorRect = get_node("%ColorRect")
@onready var loading_text = get_node("%LoadingText")
@onready var spinning_star = get_node("%SpinningStar")

var is_loading : bool = false
var is_transitioning : bool = false
var loader: ResourceLoader
var loading_complete: bool = false
var loading_dots_timer: float = 0.0
var loading_dots_count: int = 1

@onready var action_level_list = {
	"Level1": "res://ActionLevels/Level1/Level1_Forest.tscn",
	"Level2": "res://ActionLevels/Level2/Level2_Beach.tscn",
	"Level3": "res://ActionLevels/Level3/Level3_City.tscn",
	"SpecialBeachLevel": "res://ActionLevels/SpecialBeachLevel/SpecialBeachLevel.tscn",
	"GameOver": "res://Menus/GameOver.tscn",
	"ComputerScreen": "res://ActionLevels/Room/ComputerScreen.tscn",
	"Intro": "res://Cutscenes/Intro.tscn",
	"Bedroom": "res://ActionLevels/Room/Bedroom/Bedroom.tscn",
	"DialogueStage": "res://ActionLevels/Level1/LevelDialogueStage.tscn",
	"TitleScreen" : "res://Menus/MainMenu.tscn",
	"DemoEndCredits": "res://Menus/DemoEndCredits.tscn",
	"DemoIntroScreen": "res://Menus/DemoIntroScreen.tscn"
}

func _ready():
	self.visible = true
	spinning_star.visible = false
	loading_text.visible = false
	Events.connect("transition_to_scene", Callable(self, "_transition_to_next_scene"))
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(color_rect, "hide"))

func can_process_input() -> bool:
	return not is_transitioning

func get_scene_path(scene_name):
	if scene_name in action_level_list:
		return action_level_list[scene_name]
	else:
		print("Scene not present in action level list")

func _transition_to_next_scene(_next_scene, skip_loading_screen := false):
	if loader != null:
		print("Scene loading already in progress, ignoring request for ", _next_scene)
		return
	
	is_transitioning = true
	color_rect.show()

	if skip_loading_screen:
		spinning_star.visible = false
		loading_text.visible = false
	else:
		spinning_star.visible = true
		loading_text.visible = true
		loading_dots_timer = 0.0
		loading_dots_count = 1
		loading_text.text = "Loading."
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 1, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	var scene_path = get_scene_path(_next_scene)
	if scene_path and !is_loading:
		is_loading = true
		if skip_loading_screen:
			await _load_scene_fast(scene_path)
		else:
			await _load_scene_async(scene_path)

func _load_scene_async(scene_path: String):
	loading_complete = false
	var error = ResourceLoader.load_threaded_request(scene_path)

	if error != OK:
		print("Failed to start loading scene: ", scene_path)
		return

	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path)

		var progress_array = []
		ResourceLoader.load_threaded_get_status(scene_path, progress_array)
		var progress = progress_array[0] if progress_array.size() > 0 else 0.0
		_update_loading_progress(progress)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			loading_complete = true
			is_loading = false
			var resource = ResourceLoader.load_threaded_get(scene_path)

			if resource and resource is PackedScene:
				get_tree().change_scene_to_packed(resource)
				var fade_tween = get_tree().create_tween()
				fade_tween.tween_property(color_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
				await fade_tween.finished
				is_transitioning = false
			else:
				print("Failed to load scene resource")
				is_transitioning = false
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			print("Error loading scene: ", scene_path)
			is_loading = false
			is_transitioning = false
			break

		await get_tree().process_frame

func _load_scene_fast(scene_path: String):
	var resource = load(scene_path)
	is_loading = false
	
	if resource and resource is PackedScene:
		get_tree().change_scene_to_packed(resource)
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(color_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		await fade_tween.finished
		is_transitioning = false
	else:
		print("Failed to load scene resource")
		is_transitioning = false

func _update_loading_progress(progress: float):
	loading_dots_timer += get_process_delta_time()
	
	if loading_dots_timer >= 0.5:
		loading_dots_timer = 0.0
		loading_dots_count = (loading_dots_count % 3) + 1
		
		var dots = ""
		for i in range(loading_dots_count):
			dots += "."
		
		loading_text.text = "Loading" + dots

func get_loading_progress() -> float:
	if is_loading:
		var progress_array = []
		ResourceLoader.load_threaded_get_status("", progress_array)
		return progress_array[0] if progress_array.size() > 0 else 0.0
	return 1.0 if loading_complete else 0.0
