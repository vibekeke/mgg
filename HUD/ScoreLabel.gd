extends Node2D

@onready var animation = get_node("%AnimationPlayer")
@onready var label = get_node("%Label")

#Set this value to whatever is needed,
var score = 10 
var start_position = Vector2(0,0)
var outline_color = Color(0.24, 0.80, 1)
var size = 1.0

func _ready():
	label.text = "+" + str(score)
	position = start_position
	scale = Vector2(size, size)

	label.add_theme_color_override("font_outline_modulate", outline_color)
	
	animation.play("slide_up")
	

func _destroy_self():
	queue_free()
