extends AnimatedSprite

export var scroll_speed : float = 500.0

func _ready():
	AudioManager.play_random_pitch("explosion", 0.08)
	pass

func _process(delta):
	self.position.x -= delta * scroll_speed

func _on_AnimatedEnemyExplosion_animation_finished():
	self.queue_free()
