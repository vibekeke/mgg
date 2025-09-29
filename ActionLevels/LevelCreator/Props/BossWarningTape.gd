extends Node2D

@onready var timer : Timer = get_node("%Timer")
@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

@onready var background_layer : CanvasLayer = get_node("%BackgroundLayer")
@onready var visible_elements_layer : CanvasLayer = get_node("%VisibleElementsLayer")

@onready var color_rect : ColorRect = get_node("%ColorRect")
var color_rect_tween : Tween
@onready var warning_symbol : Sprite2D = get_node("%WarningSymbol")
var color_rect_tween_modulate_values = [Color(1.0,1.0,1.0,0.8), Color(1.0,1.0,1.0,0.0)]

signal warning_finished

func start_animation():
	background_layer.visible = true
	visible_elements_layer.visible = true
	tween_background_color()
	animation_player.play("boss_approaching")
	timer.start()
	AudioManager.playSFX("boss_warning", 1.0, -20)

func _ready():
	background_layer.visible = false
	visible_elements_layer.visible = false

func tween_background_color():
	color_rect.visible = true

	color_rect_tween = get_tree().create_tween()
	color_rect_tween.tween_property(color_rect, "modulate", color_rect_tween_modulate_values[1], 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	color_rect_tween.connect("finished", Callable(self, "_on_tween_completed"))

func _on_tween_completed():
	var temp = color_rect_tween_modulate_values[0]
	color_rect_tween_modulate_values[0] = color_rect_tween_modulate_values[1]
	color_rect_tween_modulate_values[1] = temp

	color_rect_tween = get_tree().create_tween()
	color_rect_tween.tween_property(color_rect, "modulate", color_rect_tween_modulate_values[1], 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	color_rect_tween.connect("finished", Callable(self, "_on_tween_completed"))

func _on_Timer_timeout():
	animation_player.play_backwards("boss_approaching")
	await animation_player.animation_finished

	if color_rect_tween != null and color_rect_tween.is_valid():
		color_rect_tween.kill()
	background_layer.visible = false
	visible_elements_layer.visible = false
	emit_signal("warning_finished")
