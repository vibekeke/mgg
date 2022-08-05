extends Path2D

onready var star = preload("Star.tscn")

const SIZE = 100
const NUM_POINTS = 36

func _ready():
	curve = Curve2D.new()
	for i in NUM_POINTS:
		if i % 6 == 0:
			print(Vector2(0, -SIZE).rotated((i / float(NUM_POINTS)) * TAU))
			var star_node = star.instance()
			star_node.set_name('star' + str(i))
			star_node.set_position(Vector2(0, -SIZE).rotated((i / float(NUM_POINTS)) * TAU))
			$PathFollow2D.add_child(star_node)
		curve.add_point(Vector2(0, -SIZE).rotated((i / float(NUM_POINTS)) * TAU))
	curve.add_point(Vector2(0,-SIZE))
	print()

func _process(delta):
	$PathFollow2D.offset += 250 * delta
	#print(self.get_curve().get_baked_points())
