extends Area2D

onready var computer_screen_2d = get_node("%ComputerScreen2D")
onready var player_sit_position = get_node("%PlayerSitPosition")
onready var overworld_player = get_node("%OverworldPlayer")

var player_in_area : bool = false
var screen_up : bool = false

func _ready():
	self.connect("body_entered", self, "_on_computer_area_entered")
	self.connect("body_exited", self, "_on_computer_area_exited")
	
func _on_computer_area_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true
	
func _on_computer_area_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false
		
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		if !screen_up:
			screen_up = true
			computer_screen_2d.appear()
			overworld_player.is_controlled = true
			overworld_player.set_facing_direction(Vector2(0, -1))
			overworld_player.global_position = player_sit_position.global_position
#		else:
#			screen_up = false
#			computer_screen_2d.appear_reverse()
#			overworld_player.is_controlled = false
