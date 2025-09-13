extends CanvasLayer

onready var scrolling = $CreditScroll

onready var animation_player = $AnimationPlayer

onready var message_text = get_node("%MessageText")
onready var message_buttons = get_node("%MessageButtons")
onready var credits_text = get_node("%CreditsText")
onready var credits_buttons = get_node("%CreditsButtons")

onready var link_cursor = load("res://imported_assets/hand_small_point_n.png")

var scroll_speed: float = 80.0

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("pop_in")
	message_text.show()
	message_buttons.show()
	credits_text.hide()
	AudioManager.play_music("credits", -10)
	Input.set_custom_mouse_cursor(link_cursor, Input.CURSOR_POINTING_HAND)

func _process(delta):
	scrolling.position.y -= scroll_speed * delta

func _on_BackButton_pressed():
	AudioManager.playSFX("mouse_click")
	toggle_text()

func _on_TitleButton_pressed():
	AudioManager.playSFX("mouse_click")
	AudioManager.stop_music()
	Events.emit_signal("transition_to_scene", "TitleScreen", false)

func _on_NextButton_pressed():
	AudioManager.playSFX("mouse_click")
	toggle_text()

func toggle_text():
	if message_text.is_visible():
		message_text.hide()
		message_buttons.hide()
		credits_text.show()
		credits_buttons.show()
	else:
		message_text.show()
		message_buttons.show()
		credits_text.hide()
		credits_buttons.hide()

func pop_in_sound():
	AudioManager.playSFX("ui_pop_in")


func _on_CreditsText_meta_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	AudioManager.playSFX("mouse_click")
	OS.shell_open(str(meta))
