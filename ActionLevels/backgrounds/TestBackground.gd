extends CanvasLayer

# Use signals instead of timer????

export (float) var scrolling_speed_middleground = 500.0
export (float) var scrolling_time_middleground = 10.0

export (float) var scrolling_speed_foreground = 500.0
export (float) var scrolling_time_foreground = 20.0

export (float) var scrolling_speed_ending = 500.0
export (float) var scrolling_time_ending = 10.0

var basic_timer = 0.0
var foreground_stopped = false
var timer_been_set = false
var timer


func _physics_process(delta):
	basic_timer += delta
	if basic_timer < scrolling_time_middleground:
		$Middleground.scroll_offset.x -= scrolling_speed_middleground * delta
	if basic_timer < scrolling_time_foreground:
		$Foreground.scroll_offset.x -= scrolling_speed_foreground * delta
	else:
		foreground_stopped = true
#	if basic_timer / scrolling_time_middleground >= 0.3:
#		$BackgroundDude.position.x -= scrolling_speed_middleground * 10 * delta
	if (scrolling_time_foreground - basic_timer) <= 3.5 and foreground_stopped == false:
#		print($Ending/ParallaxLayer/Sprite.position)
#		print($Ending/ParallaxLayer.position)
		$Ending/ParallaxLayer/Sprite.visible = true
		$Ending.scroll_offset.x -= scrolling_speed_ending * delta
