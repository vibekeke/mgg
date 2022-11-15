extends CanvasLayer

export (float) var base_scrolling_speed = 500.0

var foreground_stopped = false
var timer_been_set = false

func _physics_process(delta):
	$CloudBackground.scroll_offset.x -= base_scrolling_speed * 0.25 * delta
	$BuildingsFarmostBackground.scroll_offset.x -= base_scrolling_speed * 0.5 * delta
	$BuildingsMiddlemostBackground.scroll_offset.x -= base_scrolling_speed * 0.75 * delta
	$BuildingsFrontmostBackground.scroll_offset.x -= base_scrolling_speed * delta
