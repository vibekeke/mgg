extends ParallaxBackground

export (float) var scrolling_speed = 500.0
export (float) var scrolling_time = 10
var basic_timer = 0
var has_stopped := false
var has_changed := false

func _process(delta):
	basic_timer += delta
	if basic_timer < scrolling_time:
		scroll_offset.x -= scrolling_speed * delta
		has_stopped = true
	else:
#		$Forest.set_mirroring(Vector2.ZERO)
		var slow_x = ($Forest.motion_scale.x - 0.1) * delta
		slow_x = clamp(slow_x, 0, 1)
		print(slow_x)
		$Forest.set_motion_scale(Vector2(slow_x, $Forest.motion_scale.y))
		scroll_offset.x -= scrolling_speed * delta
#		$Forest/Sprite.position.x -= scrolling_speed * delta
#		$OrangeForest.visible = true
#		has_changed = true
#	if has_stopped and has_changed:
#		scroll_offset.x -= scrolling_speed * delta
