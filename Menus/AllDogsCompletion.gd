extends Control

@onready var animation_player : AnimationPlayer = get_node("%AnimationPlayer")

signal all_dogs_message_finished

func _ready():
	display_message()

func display_message():
	animation_player.play("display_message")
	await get_tree().create_timer(2.0).timeout
	animation_player.queue("hide_message")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide_message":
		self.emit_signal("all_dogs_message_finished")
