extends Node2D

onready var scrolling = $CreditScroll

onready var message_text = $TextureRect/MessageText
onready var message_button = $TextureRect/NextButton
onready var credits_text = $TextureRect/CreditsText
onready var credits_buttons = $TextureRect/CreditsButtons

var scroll_speed: float = 40.0




# Called when the node enters the scene tree for the first time.
func _ready():
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
	toggle_text()


func _on_TitleButton_pressed():
	#TODO: it dont work, and I don't know why :T
	Events.emit_signal("transition_to_scene", "TitleScreen")


func _on_NextButton_pressed():
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

