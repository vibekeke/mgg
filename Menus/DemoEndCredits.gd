extends Node2D

onready var scrolling = $CreditScroll

onready var animation_player = $AnimationPlayer

onready var message_text = get_node("%MessageText")
onready var message_button = get_node("%NextButton")
onready var credits_text = get_node("%CreditsText")
onready var credits_buttons = get_node("%CreditsButtons")



var scroll_speed: float = 70.0




# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("pop_in")
	message_text.show()
	message_button.show()
	credits_text.hide()
	credits_text.hide()

func _process(delta):
	scrolling.position.y -= scroll_speed * delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	AudioManager.playSFX("mouse_click")
	toggle_text()


func _on_TitleButton_pressed():
	AudioManager.playSFX("mouse_click")
	Events.emit_signal("transition_to_scene", "TitleScreen", false)


func _on_NextButton_pressed():
	AudioManager.playSFX("mouse_click")
	toggle_text()

func toggle_text():
	if message_text.is_visible():
		message_text.hide()
		message_button.hide()
		credits_text.show()
		credits_buttons.show()
	else:
		message_text.show()
		message_button.show()
		credits_text.hide()
		credits_buttons.hide()

func pop_in_sound():
	AudioManager.playSFX("ui_pop_in")



func _on_CreditsText_meta_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	AudioManager.playSFX("mouse_click")
	OS.shell_open(str(meta))
