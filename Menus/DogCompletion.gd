extends CanvasLayer

onready var animation_player = $AnimationPlayer
export var duration : float  = 5

func _ready():
	animation_player.play("fade_in")
	AudioManager.playSFX("small_win")
	

func display_for_seconds():
	yield(get_tree().create_timer(duration), "timeout")
	animation_player.play("fade_out")

func delete_self():
	queue_free()
