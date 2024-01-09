extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)
var initial_position_set := false
var move_direction := Vector2.ZERO
export var speed := 700

func _ready():
	Events.connect("player_global_position", self, "_on_player_global_position")

func _on_player_global_position(player_global_position):
	if not initial_position_set:
		Events.disconnect("player_global_position", self, "_on_player_global_position")
		initial_position_set = true
		move_direction = (player_global_position - enemy_node.global_position).normalized()
		
func _physics_process(delta):
	if initial_position_set:
		enemy_node.global_position += move_direction * speed * delta
