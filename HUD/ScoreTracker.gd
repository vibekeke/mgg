extends MarginContainer

onready var score_total : RichTextLabel = get_node("%ScoreTotal")
export var score_popup : PackedScene

func _ready():
	ScoreManager.connect("score_updated", self, "_on_score_updated")
	Events.connect("score_popup_requested", self, "spawn_score_popup")

func _on_score_updated(new_score: int):
	if new_score > 9999999:
		score_total.bbcode_text = "∞!!!"
	else:
		score_total.bbcode_text = str(new_score)

func spawn_score_popup(type, position):
	var popup = score_popup.instance()
	
	var offset = Vector2(0, -40)
	var random_offset = Vector2(rand_range(-15.0, 15.0), rand_range(-15.0, 15.0))
	var amount = 0
	
	match type:
		"enemy":
			amount = ScoreManager.DEFAULT_ENEMY_SCORE
		"star":
			amount = ScoreManager.DEFAULT_STAR_SCORE
			popup.size = 1.2
		"dog":
			amount = ScoreManager.DEFAULT_DOG_SCORE
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
