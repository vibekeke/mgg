extends AnimatedSprite

export var scroll_speed : float = 500.0

func _ready():
	pass

func _process(delta):
	self.position.x -= delta * 1.25 * scroll_speed

func _on_AnimatedEnemyExplosion_animation_finished():
	self.queue_free()
