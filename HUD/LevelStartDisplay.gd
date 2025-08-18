extends CanvasLayer

onready var controls_panel : PanelContainer = get_node("%Controls")
onready var tutorial_confirmation_panel : PanelContainer = get_node("%TutorialConfirmation")
onready var bubbles : Sprite = get_node("%Bubbles")

onready var controls_animation_player : AnimationPlayer = get_node("%ControlsAnimationPlayer")
onready var confirmation_animation_player : AnimationPlayer = get_node("%ConfirmationAnimationPlayer")
onready var text_animation_player : AnimationPlayer = get_node("%TextAnimationPlayer")
onready var ready_to_start_level_timer : Timer = get_node("%ReadyToStartLevelTimer")

var tutorial_text_displayed : bool = false
var level_start_confirmed : bool = false

signal confirm_level_start

func _ready():
	start_level_display()

func start_level_display():
	controls_animation_player.play("display_controls")

func _on_ReadyToStartLevelTimer_timeout():
	confirmation_animation_player.play("confirmation_animation")
	text_animation_player.play("confirmation_text_flash")

func _on_ControlsAnimationPlayer_animation_finished(anim_name):
	ready_to_start_level_timer.start()

func _input(event):
	if event.is_action_pressed("confirm_action") && !level_start_confirmed && tutorial_text_displayed:
		level_start_confirmed = true
		self.emit_signal("confirm_level_start")
		controls_panel.visible = false
		tutorial_confirmation_panel.visible = false
		bubbles.visible = false


func _on_ConfirmationAnimationPlayer_animation_finished(anim_name):
	tutorial_text_displayed = true
