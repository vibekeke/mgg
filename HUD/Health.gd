extends Control

const _node_name_prefix = 'health'
onready var animated_heart_sprite = preload("HeartSprite.tscn")
var has_set_max_health = false

var max_player_health

var hurt_heart_amount = 0

func _ready():
	Events.connect("player_max_health", self, "_on_player_max_health")
	Events.connect("player_damaged", self, "_on_player_damaged")
	Events.connect("collected_heart", self, "_on_collected_heart")


func _on_collected_heart():
	var heart_to_restore = last_heart_with_dead_state()
	if heart_to_restore != null:
		heart_to_restore.call_anim("default")


func _on_player_max_health(max_health):
	max_player_health = max_health
	for i in max_health:
		var health_sprite_node = animated_heart_sprite.instance()
		health_sprite_node.set_name(_node_name_prefix + str(i + 1))
		self.add_child(health_sprite_node)
	if Events.is_connected("player_max_health", self, "_on_player_max_health"):
		Events.disconnect("player_max_health", self, "_on_player_max_health")

func last_heart_with_dead_state():
	var hboxChildren = self.get_children()
	for heart in hboxChildren:
		if heart.get_current_anim() == "dead" || heart.get_current_anim() == "hurt":
			return heart
	return null

func last_heart_with_alive_state():
	var hboxChildren = self.get_children()
	hboxChildren.invert()
	for heart in hboxChildren:
		if heart.get_current_anim() == "default":
			return heart
	return null

func _on_player_damaged(damage):
	var heart_to_damage = last_heart_with_alive_state()
	if heart_to_damage != null:
		heart_to_damage.call_anim("hurt")
