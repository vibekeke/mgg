extends MarginContainer

onready var score_total : RichTextLabel = get_node("%ScoreTotal")
export var score_popup : PackedScene
var internal_score : int = 0
const DEFAULT_ENEMY_SCORE : int = 10
const DEFAULT_STAR_SCORE : int = 50
const DEFAULT_DOG_SCORE : int = 150

func _ready():
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	Events.connect("collected_dog", self, "_on_collected_dog")
	Events.connect("collected_star", self, "_on_collected_star")
	Events.connect("score_popup_requested", self, "spawn_score_popup")

func _on_collected_star():
	internal_score += DEFAULT_STAR_SCORE
	score_total.bbcode_text = str(internal_score)
	Events.update_score(internal_score)

func _on_collected_dog(_dog_type):
	internal_score += DEFAULT_DOG_SCORE
	score_total.bbcode_text = str(internal_score)
	Events.update_score(internal_score)
	Events.update_dogs(_dog_type)

func _on_regular_enemy_death():
	internal_score += DEFAULT_ENEMY_SCORE
	score_total.bbcode_text = str(internal_score)
	Events.update_score(internal_score)


func spawn_score_popup(type, position):
	var popup = score_popup.instance()
	
	var offset = Vector2(0, -40)
	var random_offset = Vector2(rand_range(-15.0, 15.0), rand_range(-15.0, 15.0))
	var amount = 0
	
	match type:
		"enemy":
			amount = DEFAULT_ENEMY_SCORE
		"star":
			amount = DEFAULT_STAR_SCORE
			popup.size = 1.2
		"dog":
			amount = DEFAULT_DOG_SCORE
			popup.outline_color = Color(1, 0.71, 0.32)
			popup.size = 1.4
		_:
			push_warning("ScoreTracker: Requested unknown score_label")
	
	popup.score = amount
	
	var target_pos = position + offset + random_offset
	var viewport_size = get_viewport().size
	var clamped_pos = Vector2(
		clamp(target_pos.x, 0, viewport_size.x - 70),
		clamp(target_pos.y, 0, viewport_size.y))
	popup.start_position = clamped_pos
	var canvas_layer = get_tree().current_scene.get_node("PopupLayer")
	canvas_layer.add_child(popup)
