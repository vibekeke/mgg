extends Node

class_name LevelEvent

var event_number : int

func trigger() -> void:
	print("trigger - override this")
	pass

func event() -> void:
	print("event - override this")
	pass
	
func end_event() -> void:
	print("end_event - override this")
	pass
