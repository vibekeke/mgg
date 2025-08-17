extends Control

var level_to_retry = null
var faded_in = false
onready var animation_player = $AnimationPlayer
onready var retry_button = get_node("%RetryButton")

func _ready():
	animation_player.play("fade_in")

func _on_RetryButton_pressed():
	if faded_in:
		Events.emit_signal("transition_to_scene", "Level1")

func _on_QuitButton_pressed():
	if faded_in:
		get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		faded_in = true
		retry_button.grab_focus()
