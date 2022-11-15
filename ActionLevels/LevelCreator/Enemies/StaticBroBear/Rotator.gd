extends Node2D

class_name BroBearRotator

onready var secret_rotator = get_node("%SecretRotator")

var rotator_has_fired = false

func _physics_process(delta):
	if secret_rotator != null && !rotator_has_fired:
		self.global_position = secret_rotator.global_position
