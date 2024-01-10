extends EnemyBase

onready var path_follow_2d = get_node("%PathFollow2D")
export var path_follow_speed = 600
var on_screen := false

func _physics_process(delta):
	if on_screen:
		path_follow_2d.offset += path_follow_speed * delta

func _on_VisibilityNotifier2D_screen_entered():
	print("is on screen")
	on_screen = true
