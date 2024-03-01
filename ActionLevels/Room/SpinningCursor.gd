extends RichTextLabel

onready var animation_player = get_node("%AnimationPlayer")

func _ready():
	animation_player.play("spinning_cursor")
