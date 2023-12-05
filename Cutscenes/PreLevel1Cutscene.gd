extends Node2D


func _ready():
	pass

func _on_Dialog_timeline_end(timeline_name):
	Events.emit_signal("transition_to_scene", "ComputerScreen")
