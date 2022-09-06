extends Node2D
class_name Hurtable

onready var lifetime = Timer.new()

var player_local_position = Vector2(0,0)
var location_offset = Vector2(0,0)

func _ready():
	lifetime.connect("timeout", self, "_on_death_cleanup")
	Events.connect("player_local_position", self, "_on_player_local_position")
	ready_lifetime()

func ready_lifetime():
	lifetime.set_wait_time(0.15)
	add_child(lifetime)
	lifetime.start()

func _on_death_cleanup():
	queue_free()

func _on_player_local_position(_player_local_position):
	self.player_local_position = _player_local_position

# doesnt live for long but should be tied to the player, signal is probably ok for this
# but accessing the node directly from here might be faster/more accurate
func follow_player_coordinates():
	if self.player_local_position != Vector2(0,0):
		self.position.y = self.player_local_position.y + location_offset.y
		self.position.x = self.player_local_position.x + location_offset.x

func _process(delta):
	follow_player_coordinates()
