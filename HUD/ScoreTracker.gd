extends MarginContainer

onready var score_total : RichTextLabel = get_node("%ScoreTotal")

func _ready():
	ScoreManager.connect("score_updated", self, "_on_score_updated")

func _on_score_updated(new_score: int):
	score_total.bbcode_text = str(new_score)
