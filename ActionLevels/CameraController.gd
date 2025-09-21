extends Camera2D

var trauma : float = 0.0
var trauma_power : int = 2
var decay : float = 1.2
var max_offset : Vector2 = Vector2(20, 15)
var max_roll : float = 0.02

var noise : OpenSimplexNoise
var noise_y : int = 0

func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

	Events.connect("player_damaged", self, "_on_player_damaged")

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		offset = Vector2.ZERO
		rotation = 0

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1

	var offset_x = max_offset.x * amount * noise.get_noise_2d(noise.seed, noise_y)
	var offset_y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	var roll = max_roll * amount * noise.get_noise_2d(noise.seed * 3, noise_y)

	offset = Vector2(offset_x, offset_y)
	rotation = roll

func _on_player_damaged(damage):
	add_trauma(0.65)

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
