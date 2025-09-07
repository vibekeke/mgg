extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var next_button = get_node("%NextButton")


#TODO: Fetch stats and update the scores
#Preferably with cool colors or something.

#TODO: Calculate some sort of grade based on the score :P
#Need to figure out the max possible score for the S+ rank


func _ready():
	animation_player.play("fade_in")
	AudioManager.playSFX("you_win")
	next_button.grab_focus()

func _playTextSound():
	AudioManager.playSFX("ui_hover")

func _playTextSound2():
	AudioManager.playSFX("coin")

func _on_NextButton_pressed():
	animation_player.play("fade_out")
	AudioManager.playSFX("ui_confirm")
	Events.emit_signal("transition_to_scene", "Intro", false)
