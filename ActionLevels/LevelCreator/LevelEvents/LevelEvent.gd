extends Node

class_name LevelEvent

signal loading_complete

var event_number : int
var event_name : String
var is_loading_complete : bool = false

func trigger() -> void:
	print("trigger - override this")
	pass

func event() -> void:
	print("event - override this")
	pass
	
func end_event() -> void:
	print("end_event - override this")
	pass

func mark_loading_complete():
	if not is_loading_complete:
		is_loading_complete = true
		print("LevelEvent ", event_name, ": Loading complete")
		emit_signal("loading_complete")

func get_loading_complete() -> bool:
	return is_loading_complete
