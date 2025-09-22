extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var next_button = get_node("%NextButton")

onready var score_label = get_node("%ScoreLabel")
onready var damage_label = get_node("%DamageLabel")
onready var dogs_label = get_node("%DogsLabel")
onready var grade_label = get_node("%GradeLabel")

onready var damage_sparkles = get_node("%DamageSparkles")
onready var grade_sparkles = get_node("%GradeSparkles")

onready var no_damage_label = get_node("%NoDamageLabel")
onready var no_float_label = get_node("%NoFloatLabel")
onready var big_score_label = get_node("%BigScoreLabel")
onready var pacifist_label = get_node("%PacifistLabel")

onready var high_score = SaveFileManager.get_high_score()

var default_outline_color = Color(0.11, 0.31, 0.52, 1)

func _ready():
	animation_player.play("fade_in")
	AudioManager.playSFX("you_win")
	damage_sparkles.hide()
	grade_sparkles.hide()
	var current_score : int = ScoreManager.get_score()
	score_label.text = str(current_score)
	score_label.add_color_override("font_outline_modulate", default_outline_color)
	
	if current_score > high_score:
		SaveFileManager.set_high_score(current_score)
	
	var damage = ScoreManager.get_hits()
	if damage == 0:
		damage_label.text = "None!"
		damage_label.add_color_override("font_outline_modulate", Color(0.01, 0.63, 0.75, 1)) #green
		damage_sparkles.visible = true
	else:
		damage_label.text = str(damage)	
		damage_label.add_color_override("font_outline_modulate", Color(0.42, 0.10, 0.18, 1)) #red
	
	dogs_label.text = str(ScoreManager.get_dog_count()) + "/3"
	dogs_label.add_color_override("font_outline_modulate", default_outline_color)
	
	no_damage_label.hide()
	no_float_label.hide()
	big_score_label.hide()
	pacifist_label.hide()
	
	var grade = ScoreManager.calculate_rank()
	grade_label.text = grade
	
	var grade_color = Color(1, 1, 1, 1)
	var grade_outline_color = default_outline_color
	
	match grade:
		"S":
			grade_color = Color(0.63, 0.99, 1, 1)
			grade_outline_color = Color(0.0, 0.48, 0.65, 1)
			grade_sparkles.visible = true
		"A":
			grade_color = Color(0.48, 0.96, 0.73, 1) 
			grade_outline_color = Color(0.00, 0.45, 0.30, 1)
		"B":
			grade_color = Color(0.96, 0.89, 0.48, 1) 
			grade_outline_color = Color(0.62, 0.40, 0.05, 1)
		"C":
			grade_color = Color(1, 0.58, 0.3, 1) 
			grade_outline_color = Color(0.62, 0.20, 0.0, 1)
		"D":
			grade_color = Color(1, 0.38, 0.48, 1) 
			grade_outline_color = Color(0.43, 0.03, 0.15, 1)
	grade_label.add_color_override("font_color", grade_color)
	grade_label.add_color_override("font_outline_modulate", grade_outline_color)
	grade_label.add_color_override("font_color_shadow", grade_outline_color)
	
	#very duct tape solution sorry, ideally we would spawn in labels as children but who caaaares its 6am
	for challenge_name in StatsTracker.drain_notification_queue():
		match challenge_name:
			"no_float_run": 
				no_float_label.show()
			"no_damage_taken_run":
				no_damage_label.show()
			"high_score_run":
				big_score_label.show()
			"pacifist_run":
				pacifist_label.show()

func _playTextSound():
	AudioManager.playSFX("ui_hover")

func _playTextSound2():
	AudioManager.playSFX("coin")

func _on_NextButton_pressed():
	AudioManager.playSFX("ui_confirm")
	animation_player.play("fade_out")
	yield(animation_player, "animation_finished")
	Events.emit_signal("transition_to_scene", "Intro", false)
