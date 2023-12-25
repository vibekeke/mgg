extends Node

onready var _parent = self.get_parent()
onready var _initial_parent_position = _parent.rect_position.y
export var enabled : bool = true

var totalTime = 0.0
export var frequency : float = 2
export var amplitude : float = 50

func _ready():
	print(_parent)

func set_enabled(_enabled):
	enabled = _enabled

func _physics_process(delta):
	if enabled:
		totalTime += delta
		var new_y = _initial_parent_position + sin(totalTime * frequency) * amplitude
		self._parent.rect_position.y = new_y
