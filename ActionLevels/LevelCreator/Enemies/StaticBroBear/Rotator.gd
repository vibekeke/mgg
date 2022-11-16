extends Node2D

class_name BroBearRotator

onready var area2d = get_node("%Area2D")

var rotator_has_fired = false

func _physics_process(delta):
	if area2d != null && rotator_has_fired == false:
		self.global_position = area2d.global_position
