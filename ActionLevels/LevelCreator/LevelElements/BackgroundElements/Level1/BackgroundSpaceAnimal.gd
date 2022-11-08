extends AnimatedSprite

export onready var rotate_around : Vector2
onready var background_dogu = get_node_or_null("../BackgroundDog")
var scroll_speed = 100

func _process(delta):
	if background_dogu == null:
		background_dogu = get_node_or_null("../BackgroundDog")

func _physics_process(delta):
	if background_dogu != null:
		self.position = background_dogu.global_position + (position - background_dogu.global_position).rotated(2 * delta)
	self.position.x += scroll_speed * delta
	if global_position.x > 2800:
		print("emitting background element offscreen space animal")
		Events.emit_signal("background_element_offscreen", DataClasses.Enemies.SPACE_ANIMAL)
		self.queue_free()
