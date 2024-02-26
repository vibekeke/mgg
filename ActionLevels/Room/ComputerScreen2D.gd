extends Node2D

onready var animation_player = get_node("%AnimationPlayer")
onready var maximise_desktop_audio = get_node("%MaximiseDesktop")
onready var minimise_desktop_audio = get_node("%MinimiseDesktop")
onready var computer_tween = get_node("%ComputerTween")
onready var desktop_background = get_node("%DesktopBackground")

onready var fullscreen_icon = get_node("%FullscreenIcon")

signal screen_open(status)

var reverse_play = false
var is_fullscreen = false
onready var initial_desktop_background_position = desktop_background.position
onready var initial_parent_position = self.position

func _ready():
	self.visible = false
	
func appear():
	emit_signal("screen_open", true)
	self.visible = true
	reverse_play = false
	maximise_desktop_audio.play(0.0)
	animation_player.play("appear")

func appear_reverse():
	emit_signal("screen_open", false)
	reverse_play = true
	minimise_desktop_audio.play(0.0)
	animation_player.play_backwards("appear")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "appear" && reverse_play:
		self.visible = true

func make_fullscreen():
	is_fullscreen = true
	desktop_background.position = Vector2.ZERO
	self.position = get_viewport_rect().size / 2
	var window_size = OS.get_window_size()
	var x_scale_value = window_size.x / desktop_background.texture.get_width()
	var y_scale_value = window_size.y / desktop_background.texture.get_height()
	computer_tween.interpolate_property(desktop_background, "scale", desktop_background.scale, Vector2(x_scale_value,y_scale_value), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	computer_tween.start()
 
func make_windowed():
	is_fullscreen = false
	desktop_background.position = initial_desktop_background_position
	self.position = initial_parent_position
	computer_tween.interpolate_property(desktop_background, "scale", desktop_background.scale, Vector2(1.0, 1.0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	computer_tween.start()

func _on_FullscreenIconArea2D_mouse_entered():
	fullscreen_icon.modulate = Color(4.0, 4.0, 4.0)


func _on_FullscreenIconArea2D_mouse_exited():
	fullscreen_icon.modulate = Color(1.0, 1.0, 1.0)


func _on_FullscreenIconArea2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouseleft") && !is_fullscreen:
		make_fullscreen()
	elif event.is_action_pressed("mouseleft") && is_fullscreen:
		make_windowed()
		
