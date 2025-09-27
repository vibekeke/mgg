extends PooledEnemy
@export var amplitude : float = 8.0 # (float, 1, 1000)
@export var frequency : float = 0.005 # (float, 1, 1000)
var start_x: float

func _ready():
	start_x = self.position.x
	initial_scroll_speed = randi() % 201 + 300

func _physics_process(delta):
	var distance_traveled = start_x - self.position.x
	var movement = cos(distance_traveled * frequency) * amplitude
	self.position.y += movement * delta
	self.position.x -= self.initial_scroll_speed * 1.50 * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("I left the screen apparently")
