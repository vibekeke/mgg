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

var first_focus = true

func _ready():
	# Set initial invisible state
	animated_sprite.modulate = Color(1, 1, 1, 0)
	sad_sprite.modulate = Color(1, 1, 1, 0)
	var current_score = ScoreManager.get_score()
	score_display.bbcode_text = score_display.bbcode_text + " " + str(current_score)
	if current_score > SaveFileManager.get_high_score():
		SaveFileManager.set_high_score(current_score)
	animation_player.play("fade_in")
	if StatsTracker.current_level_stats:
		StatsTracker.current_level_stats.last_run_completed = false
	

func _on_RetryButton_pressed():
	if faded_in:
		sad_sprite.hide()
		determined_sprite.show()
		AudioManager.playSFX("ui_confirm")
		AudioManager.fade_out_music(1.0)
		yield(get_tree().create_timer(0.5), "timeout") #Wait for the determined animation (:
		
		Events.emit_signal("transition_to_scene", "Level1", false)

func _on_QuitButton_pressed():
	if faded_in:
		AudioManager.fade_out_music(1.0)
		Events.emit_signal("transition_to_scene", "TitleScreen", false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		faded_in = true
		retry_button.grab_focus()

func _on_RetryButton_focus_entered():
	if first_focus:
		first_focus = false
	else:
		AudioManager.playSFX("ui_hover")
	retry_star.visible = true


func _on_RetryButton_focus_exited():
	retry_star.visible = false


func _on_RetryButton_mouse_entered():
	retry_button.grab_focus()



func _on_QuitButton_focus_entered():
	AudioManager.playSFX("ui_hover")
	quit_star.visible = true
	

func _on_QuitButton_focus_exited():
	quit_star.visible = false


func _on_QuitButton_mouse_entered():
	quit_button.grab_focus()
	
func play_game_over_music():
	AudioManager.play_music("game_over", 10.0)
	
