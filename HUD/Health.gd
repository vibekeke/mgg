extends Control

const _node_name_prefix = 'health'
onready var heart_sprite = preload("HeartSprite.tscn")
var has_set_max_health = false

func _ready():
	Events.connect("player_max_health", self, "_on_player_max_health")
	Events.connect("player_damaged", self, "_on_player_damaged")

func _on_player_max_health(max_health):
	for i in max_health:
		var health_sprite_node = heart_sprite.instance()
		health_sprite_node.set_name(_node_name_prefix + str(i + 1))
		$HBoxContainer.add_child(health_sprite_node)
	if Events.is_connected("player_max_health", self, "_on_player_max_health"):
		Events.disconnect("player_max_health", self, "_on_player_max_health")

func _on_player_damaged(damage):
	var hboxChildren = $HBoxContainer.get_children()
	if hboxChildren.size() > 0:
		var node_to_delete = $HBoxContainer.get_children().back()
		node_to_delete.queue_free()
