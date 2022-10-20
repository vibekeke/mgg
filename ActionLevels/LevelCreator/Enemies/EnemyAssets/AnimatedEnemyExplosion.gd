extends AnimatedSprite


func _ready():
	pass


func _on_AnimatedEnemyExplosion_animation_finished():
	self.queue_free()
