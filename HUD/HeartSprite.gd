extends Control

onready var sprite = $AnimatedSprite

func _ready():
	sprite.set_animation("default")

func call_anim(anim):
	sprite.play(anim)

func get_current_anim():
	return sprite.animation

func _on_AnimatedSprite_animation_finished():
	if sprite.get_animation() == "hurt":
		call_anim("dead")
