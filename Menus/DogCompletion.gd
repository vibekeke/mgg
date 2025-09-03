extends CanvasLayer

onready var animation_player = $AnimationPlayer
export var duration : float  = 3.0

func _ready():
	animation_player.play("fade_in")
	

func display_for_seconds():
	yield(get_tree().create_timer(duration), "timeout")
	animation_player.play("fade_out")
