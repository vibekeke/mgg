extends ParallaxBackground

export (float) var scrolling_speed = 500.0
export (float) var scrolling_time = 10000000000
var basic_timer = 0

func _process(delta):
	basic_timer += delta
	if basic_timer < scrolling_time:
		scroll_offset.x -= scrolling_speed * delta
