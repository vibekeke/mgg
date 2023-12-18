extends Area2D

onready var room_light = get_node("%RoomLight")
onready var light_switch_audio = get_node("%LightSwitchAudio")
onready var overworld_player = get_node("%OverworldPlayer")

var lights_on : bool = false
var player_in_area : bool = false

func _ready():
	self.connect("body_entered", self, "_on_room_light_area_entered")
	self.connect("body_exited", self, "_on_room_light_area_exited")

func _on_room_light_area_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true
		
	
func _on_room_light_area_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false
		
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		light_switch_audio.play(0.0)
		if lights_on:
			room_light.frame = 0
			lights_on = false
			Events.emit_signal("bedroom_lights_on", lights_on)
		else:
			room_light.frame = 1
			lights_on = true
			Events.emit_signal("bedroom_lights_on", lights_on)
