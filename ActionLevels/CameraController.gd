extends Camera2D

var trauma : float = 0.0
var trauma_power : int = 2
var decay : float = 1.2
var max_offset : Vector2 = Vector2(20, 15)
var max_roll : float = 0.02

var noise : FastNoiseLite
var noise_y : int = 0

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.25
	noise.fractal_octaves = 2

	Events.connect("player_damaged", Callable(self, "_on_player_damaged"))

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		offset = Vector2.ZERO
		# rotation = 0 # Disabled to prevent gray screen

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1

	var offset_x = max_offset.x * amount * noise.get_noise_2d(noise_y, 0)
	var offset_y = max_offset.y * amount * noise.get_noise_2d(0, noise_y)

	print("CAMERA: Shake amount=", amount, " offset=", Vector2(offset_x, offset_y))

	offset = Vector2(offset_x, offset_y)
	# rotation = roll # Disabled to prevent gray screen

func _on_player_damaged(damage):
	print("CAMERA: Player damaged, adding trauma")
	add_trauma(0.65)

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
