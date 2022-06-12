extends CanvasLayer

export (PackedScene) var background
export (PackedScene) var background_end

var repeated_background = null
var latest_background = null
var repeats = 0
var max_repeats = 4

func _ready():
	repeated_background = background.instance()
	var viewport_size = get_viewport().get_visible_rect().size
	print("viewport ", viewport_size)
	add_child(repeated_background)

func place_clone(width, tex_scale):
	repeats = repeats + 1
	if repeats < max_repeats:
		var new_background = background.instance()
		new_background.position.x = width * tex_scale
		repeated_background = new_background
		add_child(repeated_background)
	else:
		var ending_screen = background_end.instance()
		ending_screen.position.x = width * tex_scale
		repeated_background = ending_screen
		add_child(repeated_background)

func move_backgrounds(children, move_value):
	for child in children:
		child.position = child.position.linear_interpolate(child.position - Vector2(10, 0), move_value)

func _process(delta):
	if repeated_background != null:
		print(repeated_background.position.x)
		if repeated_background.position.x <= 100:
			place_clone(repeated_background.texture.get_width(), repeated_background.scale.x)
		move_backgrounds(get_children(), 200 * delta)
