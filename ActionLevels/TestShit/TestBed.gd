extends BaseLevelEvent

onready var animation_player = get_node("%AnimationPlayer")

func _ready():
	animation_player.play("test")
	pass
