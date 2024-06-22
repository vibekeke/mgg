extends Control

onready var animation_player = get_node("%AnimationPlayer")

func _ready():
	Events.connect("fall_down_ui", self, "_on_fall_down_ui")
	Events.connect("go_up_ui", self, "_on_go_up_ui")

func _on_fall_down_ui():
	animation_player.play("fall_down")
	
func _on_go_up_ui():
	animation_player.play("go_up")
