extends AnimatedSprite2D

@export var scroll_speed : float = 500.0

func _ready():
	self.connect("animation_finished", Callable(self, "_on_animation_finished"))
	self.play("default")
	AudioManager.play_random_pitch("explosion", 0.2, 2)

func _process(delta):
	self.position.x -= delta * scroll_speed

func _on_animation_finished():
	self.queue_free()
