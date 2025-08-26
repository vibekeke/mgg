
extends CanvasLayer

export (float) var fade_duration := 0.5
export (String, "Level1", "Level2", "Level3", "GameOver", "None") var retry_scene

onready var color_rect = get_node("%ColorRect")
onready var tween = get_node("%Tween")
onready var loading_text = get_node("%LoadingText")
onready var spinning_star = get_node("%SpinningStar")

var is_loading : bool = false
var loader: ResourceInteractiveLoader
var loading_complete: bool = false
var loading_dots_timer: float = 0.0
var loading_dots_count: int = 1

onready var action_level_list = {
	"Level1": "res://ActionLevels/Level1/Level1_Forest.tscn",
	"Level2": "res://ActionLevels/Level2/Level2_Beach.tscn",
	"Level3": "res://ActionLevels/Level3/Level3_City.tscn",
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
	Events.connect("transition_to_scene", self, "_transition_to_next_scene")
	tween.interpolate_property(color_rect, "modulate:a", 1, 0, fade_duration)
	tween.interpolate_callback(color_rect, fade_duration, "hide")
	tween.start()

func get_scene_path(scene_name):
	if scene_name in action_level_list:
		return action_level_list[scene_name]
	else:
		print("Scene not present in action level list")

func _transition_to_next_scene(_next_scene, skip_loading_screen := false):
	if loader != null:
		print("Scene loading already in progress, ignoring request for ", _next_scene)
		return
	
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
	
	tween.interpolate_property(color_rect, "modulate:a", 0, 1, fade_duration)
	tween.start()
	yield(tween, "tween_all_completed")
	
	var scene_path = get_scene_path(_next_scene)
	if scene_path and !is_loading:
		is_loading = true
		if skip_loading_screen:
			yield(_load_scene_fast(scene_path), "completed")
		else:
			yield(_load_scene_async(scene_path), "completed")

func _load_scene_async(scene_path: String):
	loading_complete = false
	loader = ResourceLoader.load_interactive(scene_path)
	
	if not loader:
		print("Failed to start loading scene: ", scene_path)
		return
	
	while true:
		var err = loader.poll()
		
		var progress = float(loader.get_stage()) / float(loader.get_stage_count())
		_update_loading_progress(progress)
		
		if err == ERR_FILE_EOF:
			loading_complete = true
			is_loading = false
			var resource = loader.get_resource()
			loader = null
			
			if resource and resource is PackedScene:
				get_tree().change_scene_to(resource)
				tween.interpolate_property(color_rect, "modulate:a", 1.0, 0.0, fade_duration)
				tween.start()
				yield(tween, "tween_all_completed")
			else:
				print("Failed to load scene resource")
			break
		elif err != OK:
			print("Error loading scene: ", err)
			loader = null
			break
		
		yield(get_tree(), "idle_frame")

func _load_scene_fast(scene_path: String):
	var resource = load(scene_path)
	is_loading = false
	
	if resource and resource is PackedScene:
		get_tree().change_scene_to(resource)
		tween.interpolate_property(color_rect, "modulate:a", 1.0, 0.0, fade_duration)
		tween.start()
		yield(tween, "tween_all_completed")
	else:
		print("Failed to load scene resource")

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
	if loader:
		return float(loader.get_stage()) / float(loader.get_stage_count())
	return 1.0 if loading_complete else 0.0
