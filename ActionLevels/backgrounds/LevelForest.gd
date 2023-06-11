extends CanvasLayer


# left timer related stuff here for now so I can remember how it works
# in case it's necessary later

export (float) var scrolling_speed_middleground = 500.0
export (float) var scrolling_time_middleground = 10.0

export (float) var scrolling_speed_foreground = 500.0
export (float) var scrolling_time_foreground = 200.0

export (float) var scrolling_speed_ending = 500.0
export (float) var scrolling_time_ending = 10.0

var basic_timer = 0.0
var foreground_stopped = false
var timer_been_set = false

func _physics_process(delta):
	$Foreground.scroll_offset.x -= scrolling_speed_foreground * delta
	$FrontTreesBackground.scroll_offset.x -= scrolling_speed_foreground * 0.75 * delta
	$BackForestBackground.scroll_offset.x -= scrolling_speed_foreground * 0.5 * delta
	$HillBackground.scroll_offset.x -= scrolling_speed_foreground * 0.25 * delta
	$SkyBackground.scroll_offset.x -= scrolling_speed_foreground * 0.10 * delta
