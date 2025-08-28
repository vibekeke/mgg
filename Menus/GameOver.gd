extends Control

var level_to_retry = null
var faded_in = false
onready var animation_player = $AnimationPlayer
onready var retry_button = get_node("%RetryButton")
onready var quit_button = get_node("%QuitButton")

onready var determined_sprite = get_node("%GirlSitDetermined")
onready var sad_sprite = get_node("%GirlSitSad")

onready var retry_star = get_node("%StarSelectRetry")
onready var quit_star = get_node("%StarSelectQuit")

func _ready():
	animation_player.play("fade_in")

func _on_RetryButton_pressed():
	if faded_in:
		sad_sprite.hide()
		determined_sprite.show()
		yield(get_tree().create_timer(0.5), "timeout")
		
		Events.emit_signal("transition_to_scene", "Level1", false)

func _on_QuitButton_pressed():
	if faded_in:
		Events.emit_signal("transition_to_scene", "TitleScreen", false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		faded_in = true
		retry_button.grab_focus()

func _on_RetryButton_focus_entered():
	retry_star.visible = true


func _on_RetryButton_focus_exited():
	retry_star.visible = false


func _on_RetryButton_mouse_entered():
	retry_button.grab_focus()



func _on_QuitButton_focus_entered():
	quit_star.visible = true
	

func _on_QuitButton_focus_exited():
	quit_star.visible = false


func _on_QuitButton_mouse_entered():
	quit_button.grab_focus()
