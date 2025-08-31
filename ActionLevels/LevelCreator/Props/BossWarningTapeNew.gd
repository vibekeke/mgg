extends Node2D

onready var timer : Timer = get_node("%Timer")
onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

onready var color_rect : ColorRect = get_node("%ColorRect")
onready var color_rect_tween : Tween = get_node("%ColorRectTween")
var color_rect_tween_modulate_values = [Color(1.0,1.0,1.0,0.8), Color(1.0,1.0,1.0,0.0)]


func _ready():
	color_rect.visible = false
	tween_background_color()
	animation_player.play("RESET")
	animation_player.queue("boss_approaching")
	
func tween_background_color():
	color_rect.visible = true
	color_rect_tween.interpolate_property(color_rect, "modulate", color_rect_tween_modulate_values[0], color_rect_tween_modulate_values[1], 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	color_rect_tween.start()
	color_rect_tween.connect("tween_completed", self, "_on_tween_completed")

func _on_tween_completed(object, key):
	# Swap the values to create a back-and-forth pulsing effect
	var temp = color_rect_tween_modulate_values[0]
	color_rect_tween_modulate_values[0] = color_rect_tween_modulate_values[1] 
	color_rect_tween_modulate_values[1] = temp
	
	color_rect_tween.interpolate_property(color_rect, "modulate", color_rect_tween_modulate_values[0], color_rect_tween_modulate_values[1], 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	color_rect_tween.start()


func _on_Timer_timeout():
	animation_player.play_backwards("boss_approaching")
