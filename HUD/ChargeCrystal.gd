extends Control

onready var positive_action_count = 0
onready var current_frame = 0
var transition_to_next_frame = 3 # for every 3 positive actions progress frame
var stop_frames = [1,2,3,4]

func _ready():
	Events.connect("collected_star", self, "_on_positive_charge")
	Events.connect("regular_enemy_death", self, "_on_positive_charge")

func play_frame_until(start_frame: int, end_frame: int):
	$AnimatedSprite.play("default")

func _on_positive_charge():
	positive_action_count += 1
	if fmod(positive_action_count, 3) == 0:
		play_frame_until(current_frame, current_frame + 1)
		current_frame += 1

func _process(delta):
	if Input.is_action_just_pressed("right"):
		print("based")
		_on_positive_charge()


func _on_AnimatedSprite_frame_changed():
	if current_frame < 5:
		$AnimatedSprite.stop()
	if $AnimatedSprite.frame == 18:
		$AnimatedSprite.stop()
