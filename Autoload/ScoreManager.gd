extends Node

signal score_updated(new_score)

var internal_score : int = 0
var hits_taken : int = 0
var collected_dogs : int = 0

const DEFAULT_ENEMY_SCORE : int = 20
const DEFAULT_STAR_SCORE : int = 30
const DEFAULT_DOG_SCORE : int = 100

func _ready():
	Events.connect("regular_enemy_death", Callable(self, "_on_regular_enemy_death"))
	Events.connect("collected_dog", Callable(self, "_on_collected_dog"))
	Events.connect("collected_star", Callable(self, "_on_collected_star"))
	Events.connect("player_damaged", Callable(self, "_on_player_damaged"))

func reset_level_score():
	collected_dogs = 0
	internal_score = 0
	hits_taken = 0
	emit_signal("score_updated", internal_score)

func _on_collected_star():
	internal_score += DEFAULT_STAR_SCORE
	emit_signal("score_updated", internal_score)

func _on_collected_dog(dog_type):
	internal_score += DEFAULT_DOG_SCORE
	collected_dogs += 1
	if collected_dogs > 3:
		collected_dogs = 3
	emit_signal("score_updated", internal_score)
	Events.update_dogs(dog_type)

func _on_regular_enemy_death():
	internal_score += DEFAULT_ENEMY_SCORE
	emit_signal("score_updated", internal_score)

func _on_player_damaged(damage_taken):
	hits_taken += 1

func calculate_rank() -> String:
	return _calculate_rank(hits_taken, internal_score)

func _calculate_rank(hits_taken: int, score: int) -> String:
	var score_component : float = min(score / 900.0, 1.0) * 100.0
	
	var damage_penalty : float = 0.0
	if hits_taken > 0:
		damage_penalty = min(hits_taken * 12.0 + pow(hits_taken, 1.8), 70.0)

	var damage_component = max(0.0, 100.0 - damage_penalty)
	var final_rating = (damage_component * 0.55) + (score_component * 0.45)
	
	if final_rating >= 85.0:
		return "S"
	elif final_rating >= 70.0:
		return "A"
	elif final_rating >= 55.0:
		return "B"
	elif final_rating >= 40.0:
		return "C"
	else:
		return "D"

func get_score() -> int:
	return internal_score

func get_hits() -> int:
	return hits_taken

func get_dog_count() -> int:
	return collected_dogs
