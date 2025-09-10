extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var next_button = get_node("%NextButton")

onready var score_label = get_node("%ScoreLabel")
onready var damage_label = get_node("%DamageLabel")
onready var dogs_label = get_node("%DogsLabel")
onready var grade_label = get_node("%GradeLabel")

#TODO: Fetch stats and update the scores
#Preferably with cool colors or something.

#TODO: Calculate some sort of grade based on the score :P
#Need to figure out the max possible score for the S+ rank


func _ready():
	animation_player.play("fade_in")
	AudioManager.playSFX("you_win")
	next_button.grab_focus()
	score_label.text = str(ScoreManager.get_score())
	damage_label.text = "-" + str(ScoreManager.get_hits())
	grade_label.text = ScoreManager.calculate_rank()
	dogs_label.text = str(ScoreManager.get_dog_count()) + "/3"

func _playTextSound():
	AudioManager.playSFX("ui_hover")

func _playTextSound2():
	AudioManager.playSFX("coin")

func _on_NextButton_pressed():
	animation_player.play("fade_out")
	AudioManager.playSFX("ui_confirm")
	Events.emit_signal("transition_to_scene", "Intro", false)
