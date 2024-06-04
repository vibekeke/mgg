extends Node2D

onready var block = get_node("%Sprite")
export var max_y_scale = 1.0
export var min_y_scale = 0.0
export var frequency = 2.0
export var amplitude = 0.5
export var phase = 0.0
var time = 0
var new_y_scale = 0

func _ready():
	block.scale.y = min_y_scale


func _physics_process(delta):
	var mid_scale = (max_y_scale + min_y_scale) / 2.0
	var new_y_scale = amplitude * sin(2 * PI * frequency * time + phase) + mid_scale
	amplitude = (max_y_scale - min_y_scale) / 2.0
	new_y_scale = clamp(new_y_scale, min_y_scale, max_y_scale)
	block.scale.y = new_y_scale
	time += delta
