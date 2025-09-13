extends CanvasLayer

onready var how_to_panel : PanelContainer = get_node("%PanelContainer")
onready var controls_panel : PanelContainer = get_node("%Controls")
onready var tutorial_confirmation_panel : PanelContainer = get_node("%TutorialConfirmation")
onready var bubbles : Sprite = get_node("%Bubbles")

onready var controls_animation_player : AnimationPlayer = get_node("%ControlsAnimationPlayer")
onready var confirmation_animation_player : AnimationPlayer = get_node("%ConfirmationAnimationPlayer")
onready var text_animation_player : AnimationPlayer = get_node("%TextAnimationPlayer")
onready var ready_to_start_level_timer : Timer = get_node("%ReadyToStartLevelTimer")

export var before_level_dialogue : Resource
export var before_level_dialogue_script_name : String
export var level1_event1_dialog : Resource

export var hide_tutorial : bool = false
var tutorial_text_displayed : bool = false
var level_start_confirmed : bool = false

signal confirm_level_start

func _ready():
	start_level_display()
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	if hide_tutorial:
		how_to_panel.hide()

func start_level_display():
	controls_animation_player.play("display_controls")

func _on_ReadyToStartLevelTimer_timeout():
	if Events.first_time_playing:
		play_intro_dialogue()
		Events.first_time_playing = false
	else:
		play_confirmation_animations()

func play_confirmation_animations():
	confirmation_animation_player.play("confirmation_animation")
	text_animation_player.play("confirmation_text_flash")

func _on_ControlsAnimationPlayer_animation_finished(anim_name):
	ready_to_start_level_timer.start()

func _input(event):
	if event.is_action_pressed("confirm_action") && !level_start_confirmed && tutorial_text_displayed:
		level_start_confirmed = true
		self.emit_signal("confirm_level_start")
		how_to_panel.visible = false
		controls_panel.visible = false
		tutorial_confirmation_panel.visible = false
		bubbles.visible = false

func play_intro_dialogue():
	if before_level_dialogue:
		MggDialogue.create_dialogue_balloon(
				before_level_dialogue_script_name,
				before_level_dialogue, 
				self.get_instance_id(), 
				DataClasses.Placement.LOWER, 
				DataClasses.CharacterPortrait.AngelNeutral,
				Color(0.10, 0.25, 0.4, 0.60),
				Color(0.0, 0.0, 0.0, 0.25),
				false,
				3.0
			)
	else:
		play_confirmation_animations()

func _on_dialogue_box_finished(node_id_in_use):
	play_confirmation_animations()
	
func _on_ConfirmationAnimationPlayer_animation_finished(anim_name):
	tutorial_text_displayed = true
