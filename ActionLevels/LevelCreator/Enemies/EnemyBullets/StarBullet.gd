extends Node2D

onready var animation_player = get_node("%AnimationPlayer")
onready var can_gravitate_towards_player = get_node("%CanGravitateTowardsPlayer")
export var enabled := true

func _ready():
	Events.connect("kill_enemy_bullet", self, "_on_kill_enemy_bullet")
	animation_player.play("spin")
	can_gravitate_towards_player.disabled = !enabled

func set_enabled(is_enabled):
	can_gravitate_towards_player.disabled = !is_enabled

func _on_kill_enemy_bullet():
	if is_instance_valid(self):
		self.queue_free()
