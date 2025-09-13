extends Control

onready var animation_player = get_node("%AnimationPlayer")
onready var dog_collection = get_node("%DogCollection")

export var auto_start : bool = false
export var hide_dogs : bool = false

func _ready():
	Events.connect("fall_down_ui", self, "_on_fall_down_ui")
	Events.connect("go_up_ui", self, "_on_go_up_ui")
	if hide_dogs:
		dog_collection.hide()
	if auto_start:
		_on_fall_down_ui()

func _on_fall_down_ui():
	animation_player.play("fall_down")
	
func _on_go_up_ui():
	animation_player.play("go_up")
