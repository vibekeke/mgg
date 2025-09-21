extends CanvasLayer

export (float) var base_scrolling_speed = 500.0

var background_moving : bool = false

func _ready():
	Events.connect("background_moving_enabled", self, "_on_background_moving_enabled")

func _physics_process(delta):
	if background_moving:
		$SkyBackground.scroll_base_offset.x -= base_scrolling_speed * 0.10 * delta
		$CloudBackground.scroll_base_offset.x -= base_scrolling_speed * 0.25 * delta
		$BeachBackground.scroll_base_offset.x -= base_scrolling_speed * 0.5 * delta
		$BeachMiddleground.scroll_base_offset.x -= base_scrolling_speed * 0.75 * delta
		$BeachForeground.scroll_base_offset.x -= base_scrolling_speed * delta

func _on_background_moving_enabled(enabled: bool):
	background_moving = enabled


func _on_LevelStartDisplay_confirm_level_start():
	$BeachForeground/SunShine/AnimatedSprite.play()
