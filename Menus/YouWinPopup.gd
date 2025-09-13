extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var next_button = get_node("%NextButton")

onready var score_label = get_node("%ScoreLabel")
onready var damage_label = get_node("%DamageLabel")
onready var dogs_label = get_node("%DogsLabel")
onready var grade_label = get_node("%GradeLabel")

onready var damage_sparkles = get_node("%DamageSparkles")
onready var grade_sparkles = get_node("%GradeSparkles")

#TODO: Fetch stats and update the scores
#Preferably with cool colors or something.

#TODO: Calculate some sort of grade based on the score :P
#Need to figure out the max possible score for the S+ rank

var default_outline_color = Color(0.11, 0.31, 0.52, 1)

func _ready():
	animation_player.play("fade_in")
	AudioManager.playSFX("you_win")
	next_button.grab_focus()
	damage_sparkles.hide()
	grade_sparkles.hide()
	
	score_label.text = str(ScoreManager.get_score())
	score_label.add_color_override("font_outline_modulate", default_outline_color)
	
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
	
func _playTextSound():
	AudioManager.playSFX("ui_hover")

func _playTextSound2():
	AudioManager.playSFX("coin")

func _on_NextButton_pressed():
	animation_player.play("fade_out")
	AudioManager.playSFX("ui_confirm")
	Events.emit_signal("transition_to_scene", "Intro", false)
