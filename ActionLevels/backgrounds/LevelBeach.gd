extends CanvasLayer

export (float) var base_scrolling_speed = 500.0

var foreground_stopped = false
var timer_been_set = false

func _physics_process(delta):
	$SkyBackground.scroll_offset.x -= base_scrolling_speed * 0.10 * delta
	$CloudBackground.scroll_offset.x -= base_scrolling_speed * 0.25 * delta
	$BeachBackground.scroll_offset.x -= base_scrolling_speed * 0.5 * delta
	$BeachMiddleground.scroll_offset.x -= base_scrolling_speed * 0.75 * delta
	$BeachForeground.scroll_offset.x -= base_scrolling_speed * delta
