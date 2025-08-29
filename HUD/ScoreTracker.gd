extends MarginContainer

onready var score_total : RichTextLabel = get_node("%ScoreTotal")
var internal_score : int = 0
const DEFAULT_ENEMY_SCORE : int = 10
const DEFAULT_STAR_SCORE : int = 50
const DEFAULT_DOG_SCORE : int = 150

func _ready():
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	Events.connect("collected_dog", self, "_on_collected_dog")
	Events.connect("collected_star", self, "_on_collected_star")

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
