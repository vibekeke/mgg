extends AnimatedSprite
# should just hurt the player and not much else, not special
# like some other enemy projectiles

func _ready():
	var area2d = $Area2D
	if area2d != null:
		area2d.connect("body_entered", self, "_on_call_body_entered")
		area2d.connect("area_entered", self, "_on_call_area_entered")

func _on_call_body_entered(body):
	if body.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)
	
func _on_call_area_entered(area):
	if area.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)
