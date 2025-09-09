extends MarginContainer

onready var score_total : RichTextLabel = get_node("%ScoreTotal")

enum Rank {S,A,B,C,D}

var internal_rank : int = Rank.D
var internal_score : int = 0
var hits_taken : int = 0
const DEFAULT_ENEMY_SCORE : int = 10
const DEFAULT_STAR_SCORE : int = 50
const DEFAULT_DOG_SCORE : int = 150

func calculate_rank(hits_taken: int, score: int):
	var score_component : float = min(score / 900.0, 1.0) * 100.0
	
	var damage_penalty : float = 0.0
	if hits_taken > 0:
		damage_penalty = min(hits_taken * 12.0 + pow(hits_taken, 1.8), 70.0)

	var damage_component = max(0.0, 100.0 - damage_penalty)
	var final_rating = (damage_component * 0.55) + (score_component * 0.45)
	
	if final_rating >= 85.0:
		return Rank.S
	elif final_rating >= 70.0:
		return Rank.A
	elif final_rating >= 55.0:
		return Rank.B
	elif final_rating >= 40.0:
		return Rank.C
	else:
		return Rank.D

func _ready():
	Events.connect("regular_enemy_death", self, "_on_regular_enemy_death")
	Events.connect("collected_dog", self, "_on_collected_dog")
	Events.connect("collected_star", self, "_on_collected_star")
	Events.connect("player_damaged", self, "_on_player_damaged")

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

func _on_player_damaged():
	hits_taken += 1
