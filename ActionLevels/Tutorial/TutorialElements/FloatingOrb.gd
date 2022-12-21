extends Node2D

export var speed := 120
export var seconds_to_reverse := 1.5
export (int, "x direction", "y direction") var movement_direction
var timer = Timer.new()
var id := 1

func _ready():
	timer.set_name("floating_orb_timer")
	timer.set_one_shot(false)
	timer.set_wait_time(seconds_to_reverse)
	timer.connect("timeout", self, "_on_orb_movement_timeout")
	self.add_child(timer)
	timer.start()
	
func _on_orb_movement_timeout():
	speed = speed * -1

func _physics_process(delta):
	if movement_direction == 0:
		self.position.x += delta * speed
	if movement_direction == 1:
		self.position.y += delta * speed


func _on_Area2D_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		print("collided with player")
		Events.emit_signal("tutorial_element_touched", id)
		# consider going off screen rather than queue freeing so they don't need to be
		# instanced so much in tutorial
		self.queue_free()
