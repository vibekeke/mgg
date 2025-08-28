extends CanvasLayer

var is_paused = false setget set_is_paused

onready var resume_button = get_node("%ResumeBtn")
onready var retry_button = get_node("%RetryBtn")
onready var title_button = get_node("%TitleBtn")

onready var spinny_star_resume = get_node("%SpinnyStarResume")
onready var spinny_star_retry = get_node("%SpinnyStarRetry")
onready var spinny_star_title = get_node("%SpinnyStarTitle")

var vhs_filter_state_paused = {
	'overlay': true,
	'scanlines_opacity': 0.557,
	'scanlines_width': 0.128,
	'grille_opacity': 0.3,
	'resolution': Vector2(1920, 1080),
	'pixelate': true,
	'roll': true,
	'roll_speed': 1.2,
	'roll_size': 14.963,
	'roll_variation': 1.737,
	'distort_intensity': 0.034,
	'noise_opacity': 0.65,
	'noise_speed': 5,
	'static_noise_intensity': 0.06,
	'aberration': 0.007,
	'brightness': 1.2,
	'discolor': false,
	'warp_amount': 0,
	'clip_warp': false,
	'vignette_intensity': 0.4,
	'vignette_opacity': 0.256
}

var vhs_filter_state_unpaused = {
	'overlay': true,
	'scanlines_opacity': 0.159,
	'scanlines_width': 0.19,
	'grille_opacity': 0.089,
	'resolution': Vector2(1920, 1080),
	'pixelate': true,
	'roll': true,
	'roll_speed': 0.7,
	'roll_size': 6,
	'roll_variation': 3,
	'distort_intensity': 0.004,
	'noise_opacity': 0.125,
	'noise_speed': 5,
	'static_noise_intensity': 0.06,
	'aberration': 0.007,
	'brightness': 1.2,
	'discolor': false,
	'warp_amount': 0,
	'clip_warp': false,
	'vignette_intensity': 0.4,
	'vignette_opacity': 0.312
}

onready var vhs_filter = get_node_or_null("%VHS")

func look_for_vhs_filter():
	var level_background = self.get_parent().get_node_or_null("%LevelBackground")
	print("level background is", level_background)
	if level_background != null:
		vhs_filter = level_background.get_node_or_null("%VHS")

func _ready():
	look_for_vhs_filter()
	if vhs_filter == null:
		print("Could not find a node named VHS filter in this scene!")
	var parent_node = self.get_parent()
	if parent_node.name == "Bedroom":
		retry_button.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("paused"):
		self.is_paused = !is_paused

func set_vhs_shader(shader_params : Dictionary):
	for param in shader_params:
		vhs_filter.material.set_shader_param(param, shader_params[param])

func set_is_paused(value):
	is_paused = value
	if value && vhs_filter != null:
		set_vhs_shader(vhs_filter_state_paused)
	elif value == false && vhs_filter != null:
		set_vhs_shader(vhs_filter_state_unpaused)
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		resume_button.grab_focus()

func _on_ResumeBtn_pressed():
	self.is_paused = false

func _on_QuitBtn_pressed(): #Should return to title screen!
	self.is_paused = false
	Events.emit_signal("transition_to_scene", "TitleScreen", false)

func _on_BackBtn_pressed():	 #Should restart scene
	self.is_paused = false
	Events.emit_signal("transition_to_scene", "Level1", false)

func _on_ResumeBtn_focus_entered():
	spinny_star_resume.visible = true

func _on_ResumeBtn_focus_exited():
	spinny_star_resume.visible = false


func _on_BackBtn_focus_entered():
	spinny_star_retry.visible = true


func _on_BackBtn_focus_exited():
	spinny_star_retry.visible = false


func _on_QuitBtn_focus_entered():
	spinny_star_title.visible = true


func _on_QuitBtn_focus_exited():
	spinny_star_title.visible = false
	




func _on_ResumeBtn_mouse_entered():
	resume_button.grab_focus()

func _on_RetryBtn_mouse_entered():
	retry_button.grab_focus()

func _on_TitleBtn_mouse_entered():
	title_button.grab_focus()
