extends Node2D

onready var boss_warning_tape_layer = get_node("%BossWarningTapeLayer")
onready var color_rect_layer = get_node("%ColorRectLayer")

onready var warning_tape_animation_player = get_node("%WarningTapeAnimationPlayer")
onready var warning_siren = get_node("%WarningSiren")
onready var tween = get_node("%Tween")
onready var siren_timer = get_node("%SirenTimer")
onready var warning_symbol = get_node("%WarningSymbol")
onready var color_rect = get_node("%ColorRect")
onready var color_rect_tween = get_node("%ColorRectTween")

signal warning_finished

var color_rect_tween_modulate_values = [Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0.0)]
var tween_values = [Color(1.0,1.0,1.0,1.0), Color(1.5,0.5,0.5,1.0)]
var playing_tape_reverse = false

func _ready():
	boss_warning_tape_layer.visible = false
	color_rect_layer.visible = false

func run_tween():
	tween.interpolate_property(warning_symbol, "modulate", tween_values[0], tween_values[1], 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func run_color_rect_tween():
	color_rect_tween.interpolate_property(color_rect, "modulate", color_rect_tween_modulate_values[0], color_rect_tween_modulate_values[1], 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	color_rect_tween.start()

func start_animation():
	boss_warning_tape_layer.visible = true
	color_rect_layer.visible = true
	warning_tape_animation_player.play("warning_tape")

func _on_WarningTapeAnimationPlayer_animation_finished(anim_name):
	if playing_tape_reverse:
		tween.stop_all()
		color_rect_tween.stop_all()
		color_rect.visible = false
		warning_symbol.visible = false
		boss_warning_tape_layer.visible = false
		color_rect_layer.visible = false
		emit_signal("warning_finished")

func _on_SirenTimer_timeout():
	if !playing_tape_reverse:
		warning_siren.stop()
		yield(get_tree().create_timer(0.3), "timeout")
		playing_tape_reverse = true
		warning_tape_animation_player.play_backwards("warning_tape")
	
func _on_Tween_tween_completed(object, key):
	tween_values.invert()
	run_tween()

func _on_WarningTapeAnimationPlayer_animation_started(anim_name):
	if !playing_tape_reverse:
		warning_siren.play(0.0)
		siren_timer.start()
		run_tween()
		run_color_rect_tween()

func _on_ColorRectTween_tween_completed(object, key):
	color_rect_tween_modulate_values.invert()
	run_color_rect_tween()
