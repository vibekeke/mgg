extends Node

export (NodePath) var enemy
onready var enemy_node = get_node(enemy)

export (NodePath) var take_damage
onready var take_damage_node = get_node(take_damage)

export var speed := 500
export var speed_up_value := 100
var is_moving := true

func _ready():
	if is_instance_valid(take_damage_node):
		take_damage_node.connect("took_damage", self, "_on_took_damage")

func _on_took_damage(node_id):
	speed += speed_up_value

func _physics_process(delta):
	if is_moving:
		enemy_node.global_position.x -= speed * delta
