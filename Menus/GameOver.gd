extends Control

var level_to_retry = null
var faded_in = false
onready var animation_player = $AnimationPlayer
onready var retry_button = get_node("%RetryButton")
onready var quit_button = get_node("%QuitButton")

onready var determined_sprite = get_node("%GirlSitDetermined")
onready var sad_sprite = get_node("%GirlSitSad")
onready var animated_sprite = $CanvasLayer/AnimatedSprite

onready var retry_star = get_node("%StarSelectRetry")
onready var quit_star = get_node("%StarSelectQuit")

onready var score_display : RichTextLabel = get_node("%ScoreDisplay")

var player_final_score : int = 0


onready var audio_player = $AudioStreamPlayer
var hover_sfx = preload("res://sounds/UI sounds/vgmenuhover.wav")
var confirm_sfx = preload("res://sounds/UI sounds/vgmenuselect.wav")
var first_focus = true

func _ready():
	# Set initial invisible state
	animated_sprite.modulate = Color(1, 1, 1, 0)
	sad_sprite.modulate = Color(1, 1, 1, 0)
	
	player_final_score = Events.get_score()
	score_display.bbcode_text = score_display.bbcode_text + " " + str(player_final_score)
	animation_player.play("fade_in")
	audio_player.stream = hover_sfx
	

func _on_RetryButton_pressed():
	if faded_in:
		sad_sprite.hide()
		determined_sprite.show()
		audio_player.stream = confirm_sfx
		audio_player.play()
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
	if first_focus:
		first_focus = false
	else:
		audio_player.play()
	retry_star.visible = true


func _on_RetryButton_focus_exited():
	retry_star.visible = false


func _on_RetryButton_mouse_entered():
	retry_button.grab_focus()



func _on_QuitButton_focus_entered():
	audio_player.play()
	quit_star.visible = true
	

func _on_QuitButton_focus_exited():
	quit_star.visible = false


func _on_QuitButton_mouse_entered():
	quit_button.grab_focus()
