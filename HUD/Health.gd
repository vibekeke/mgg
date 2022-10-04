extends Control

const _node_name_prefix = 'health'
onready var animated_heart_sprite = preload("HeartSprite.tscn")
var has_set_max_health = false
var max_player_health
var current_heart_to_act
var hurt_heart_amount = 0

func _ready():
	Events.connect("player_max_health", self, "_on_player_max_health")
	Events.connect("player_damaged", self, "_on_player_damaged")
	Events.connect("collected_heart", self, "_on_collected_heart")

func _on_collected_heart():
	var hboxChildren = self.get_children()
	if hurt_heart_amount > 0:
		var node_to_change = hboxChildren[-1]
		if node_to_change != null:
			node_to_change.call_anim("default")
		hurt_heart_amount -= 1
		
func _on_player_max_health(max_health):
	current_heart_to_act = max_health
	max_player_health = max_health
	for i in max_health:
		var health_sprite_node = animated_heart_sprite.instance()
		health_sprite_node.set_name(_node_name_prefix + str(i + 1))
		self.add_child(health_sprite_node)
	if Events.is_connected("player_max_health", self, "_on_player_max_health"):
		Events.disconnect("player_max_health", self, "_on_player_max_health")

func _on_player_damaged(damage):
	current_heart_to_act = current_heart_to_act - 1
	var hboxChildren = self.get_children()
	if hboxChildren.size() > 0:
		var node_to_change = self.get_children()[current_heart_to_act]
		if node_to_change != null:
			node_to_change.call_anim("hurt")
			hurt_heart_amount += 1
		else:
			print("Null value for heart in health container")
