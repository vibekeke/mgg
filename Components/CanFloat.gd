extends Node

onready var _parent = self.get_parent()
onready var _initial_parent_position = _parent.global_position.y
export var enabled : bool = true
export var enable_only_when_visible : bool = false

var totalTime = 0.0
export var frequency : float = 2
export var amplitude : float = 5

func set_enabled(_enabled):
	enabled = _enabled

func floating(delta):
	totalTime += delta
	var new_y = _initial_parent_position + sin(totalTime * frequency) * amplitude
	_parent.global_position.y = new_y

func _physics_process(delta):
	if enabled:
		if enable_only_when_visible and _parent.visible:
			floating(delta)
		else:
			floating(delta)

