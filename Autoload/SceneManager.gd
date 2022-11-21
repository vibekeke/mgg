class_name SceneManager
extends CanvasLayer

export (float) var fade_duration := 0.5

onready var color_rect: ColorRect = $ColorRect
onready var tween: Tween = $Tween

onready var action_level_list = {
	"Tutorial": "res//ActionLevels/Tutorial/Level0_Tutorial.tscn",
	"Level1": "res://ActionLevels/Level1/Level1_Forest.tscn",
	"Level2": "res://ActionLevels/Level2/Level2_Beach.tscn",
	"Level3": "res://ActionLevels/Level3/Level3_City.tscn",
	"GameOver": "res://Menus/GameOver.tscn"
}

func _ready():
	Events.connect("transition_to_scene", self, "_transition_to_next_scene")
	tween.interpolate_property(color_rect, "modulate:a", 1, 0, fade_duration)
	tween.interpolate_callback(color_rect, fade_duration, "hide")
	tween.start()

func get_scene_path(scene_name):
	if scene_name in action_level_list:
		return action_level_list[scene_name]
	else:
		print("Scene not present in action level list")

func _transition_to_next_scene(_next_scene):
	color_rect.show()
	tween.interpolate_property(color_rect, "modulate:a", 0, 1, fade_duration)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene(get_scene_path(_next_scene))
