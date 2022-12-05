extends Sprite

# NOTE
# turns on/off for everything, currently only the player cares
# about the floor collision, but perhaps this can change
# if so, collision layers/masks need to be used instead
 
func turn_off_collision():
	$StaticBody2D/CollisionShape2D.disabled = true
	
func turn_on_collision():
	$StaticBody2D/CollisionShape2D.disabled = false
