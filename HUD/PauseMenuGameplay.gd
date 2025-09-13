extends CanvasLayer

var is_paused = false setget set_is_paused

export var vhs_filter_path : NodePath
onready var resume_button = get_node("%ResumeBtn")
onready var retry_button = get_node("%RetryBtn")
onready var title_button = get_node("%TitleBtn")

onready var spinny_star_resume = get_node("%SpinnyStarResume")
onready var spinny_star_retry = get_node("%SpinnyStarRetry")
onready var spinny_star_title = get_node("%SpinnyStarTitle")


onready var vhs_filter = get_node_or_null(vhs_filter_path)

func _ready():
	if vhs_filter == null:
		print("Could not find a node named VHS filter in this scene!")
	var parent_node = self.get_parent()
	if parent_node.name == "Bedroom":
		retry_button.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("paused"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	if value && vhs_filter != null:
		Events.set_vhs_shader(Events.vhs_filter_state_paused, vhs_filter)
	elif value == false && vhs_filter != null:
		Events.set_vhs_shader(Events.vhs_filter_state_unpaused, vhs_filter)
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		resume_button.grab_focus()

func _on_ResumeBtn_pressed():
	AudioManager.playSFX("ui_confirm", 0.0, 5.0)
	self.is_paused = false

func _on_QuitBtn_pressed(): #Should return to title screen!
	yield(get_tree().create_timer(0.4, true), "timeout")
	if StatsTracker.current_level_stats:
		StatsTracker.current_level_stats.last_run_completed = false
	self.is_paused = false
	Events.emit_signal("transition_to_scene", "TitleScreen", false)

func _on_BackBtn_pressed():	 #Should restart scene
	AudioManager.playSFX("ui_confirm", 0.0, 5.0)
	yield(get_tree().create_timer(0.4, true), "timeout")
	
	self.is_paused = false
	Events.emit_signal("transition_to_scene", "Level1", false)

func _on_ResumeBtn_focus_entered():
	AudioManager.playSFX("ui_hover")
	spinny_star_resume.visible = true

func _on_ResumeBtn_focus_exited():
	spinny_star_resume.visible = false


func _on_BackBtn_focus_entered():
	AudioManager.playSFX("ui_hover")
	spinny_star_retry.visible = true


func _on_BackBtn_focus_exited():
	spinny_star_retry.visible = false


func _on_QuitBtn_focus_entered():
	AudioManager.playSFX("ui_hover")
	spinny_star_title.visible = true


func _on_QuitBtn_focus_exited():
	spinny_star_title.visible = false
	


func _on_ResumeBtn_mouse_entered():
	resume_button.grab_focus()

func _on_RetryBtn_mouse_entered():
	retry_button.grab_focus()

func _on_TitleBtn_mouse_entered():
	title_button.grab_focus()
