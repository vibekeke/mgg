extends CanvasLayer

export (float) var scrolling_speed_middleground = 500.0
export (float) var scrolling_time_middleground = 10.0

export (float) var scrolling_speed_foreground = 500.0
export (float) var scrolling_time_foreground = 200.0

export (float) var scrolling_speed_ending = 500.0
export (float) var scrolling_time_ending = 10.0

var basic_timer = 0.0
var foreground_stopped = false
var timer_been_set = false
var background_moving = false

func _ready():
	Events.connect("background_moving_enabled", self, "_on_background_moving_enabled")

func _physics_process(delta):
	if background_moving:
		$Foreground.scroll_offset.x -= scrolling_speed_foreground * delta
		$FrontTreesBackground.scroll_offset.x -= scrolling_speed_foreground * 0.75 * delta
		$BackForestBackground.scroll_offset.x -= scrolling_speed_foreground * 0.5 * delta
		$HillBackground.scroll_offset.x -= scrolling_speed_foreground * 0.25 * delta
		$SkyBackground.scroll_offset.x -= scrolling_speed_foreground * 0.10 * delta

func _on_background_moving_enabled(enabled: bool):
	background_moving = enabled

func get_foreground_node():
	return $Foreground
	
func get_front_trees_background_node():
	return $FrontTreesBackground

func get_back_forest_background_node():
	return $BackForestBackground

func get_hill_background_node():
	return $HillBackground
	
func get_sky_background_node():
	return $SkyBackground
