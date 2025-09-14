extends Node

export var hide_delay: float = 2.0 
export var enabled: bool = true 
export var always_visible: bool = false  # when true, cursor never hides

var timer: Timer
var last_mouse_position: Vector2
var is_cursor_hidden: bool = false

func _ready():
	setup_timer()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	last_mouse_position = get_viewport().get_mouse_position()

func setup_timer():
	timer = Timer.new()
	timer.wait_time = hide_delay
	timer.one_shot = true
	timer.connect("timeout", self, "_on_hide_timer_timeout")
	add_child(timer)

func _input(event):
	if not enabled or always_visible:
		return

	if event is InputEventMouseMotion:
		var current_position = event.position

		# Check if mouse actually moved (not just a tiny jitter)
		if last_mouse_position.distance_to(current_position) > 1.0:
			show_cursor()
			last_mouse_position = current_position
			restart_hide_timer()

func show_cursor():
	if is_cursor_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_cursor_hidden = false

func hide_cursor():
	if not is_cursor_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		is_cursor_hidden = true

func restart_hide_timer():
	timer.stop()
	timer.start()

func _on_hide_timer_timeout():
	if not always_visible:
		hide_cursor()

func set_enabled(value: bool):
	enabled = value
	if enabled and not always_visible:
		restart_hide_timer()
	else:
		show_cursor()
		timer.stop()

func set_always_visible(value: bool):
	always_visible = value
	if always_visible:
		show_cursor()
		timer.stop()
	elif enabled:
		restart_hide_timer()

func set_hide_delay(delay: float):
	hide_delay = delay
	timer.wait_time = delay
