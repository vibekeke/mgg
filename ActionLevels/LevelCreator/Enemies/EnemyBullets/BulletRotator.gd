extends Node2D

var node_to_follow = null

func _ready():
	pass

func _physics_process(delta):
	if is_instance_valid(node_to_follow):
		self.global_position = node_to_follow.global_position
