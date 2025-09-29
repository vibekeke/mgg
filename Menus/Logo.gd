extends Sprite2D

@export var enabled := true
@export var frequency := 0.2   # bobs per second (0.2 = one bob every 5s)
@export var amplitude := 2.0   # pixels (very subtle)
@export var phase_deg := 0.0   # start offset per node (e.g., 0, 120, 240)

var _t := 0.0
var _base_y := 0.0

func _ready():
	_base_y = global_position.y

func _physics_process(delta):
	if not enabled:
		return
	_t += delta
	var phase = deg_to_rad(phase_deg)
	var offset = sin(TAU * frequency * _t + phase) * amplitude
	global_position.y = _base_y + offset
