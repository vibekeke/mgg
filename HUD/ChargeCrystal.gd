extends Control

onready var positive_action_count = 0
onready var current_frame = 0
var transition_to_next_frame = 3 # for every 3 positive actions progress frame
var stop_frames = [1,2,3,4]

func _ready():
	Events.connect("collected_star", self, "_on_positive_charge")
	Events.connect("regular_enemy_death", self, "_on_positive_charge")
	$AnimatedSprite.animation = "default"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.stop()

func play_fully_charged():
	$AnimatedSprite.speed_scale = 1.5
	$AnimatedSprite.play("complete")
	Events.emit_signal("has_charge_shot")

func play_frame_until():
	$AnimatedSprite.play("default")

func _on_positive_charge():
	if $AnimatedSprite.animation == "default":
		positive_action_count += 1
		if fmod(positive_action_count, 3) == 0:
			play_frame_until()
			current_frame += 1


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "default" and $AnimatedSprite.frame < 5:
		$AnimatedSprite.stop()
	if $AnimatedSprite.animation == "default" and $AnimatedSprite.frame == 5:
		$AnimatedSprite.play("default")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "default":
		positive_action_count = 0
		play_fully_charged()
