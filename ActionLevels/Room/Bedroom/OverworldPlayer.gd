extends CharacterBody2D

@onready var animation_tree = get_node("%AnimationTree")
@onready var overworld_reactions = get_node("%OverworldPlayerReactions")

var speed = 200
#var velocity = Vector2.ZERO
var is_controlled = false

func _ready():
	Events.connect("overworld_player_controlled", Callable(self, "_on_overworld_player_controlled"))

func _on_overworld_player_controlled(status):
	is_controlled = status
	if is_controlled:
		animation_tree.get("parameters/playback").travel("Idle")
		velocity = Vector2.ZERO
		

func set_reaction(name: String, state: bool):
	if name == "question_mark" and state:
		overworld_reactions.play_question_mark()
	elif name == "question_mark" and !state:
		overworld_reactions.remove_question_mark()

func set_facing_direction(facing_vector: Vector2):
	animation_tree.get("parameters/playback").travel("Idle")
	animation_tree.set("parameters/Idle/blend_position", facing_vector)

func get_input():
	if is_controlled:
		return
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	elif Input.is_action_pressed("move_left"):
		velocity.x -= 1
	elif Input.is_action_pressed("move_down"):
		velocity.y += 1
	elif Input.is_action_pressed("move_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	
	if velocity == Vector2.ZERO:
		animation_tree.get("parameters/playback").travel("Idle")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
		animation_tree.get("parameters/playback").travel("Walk")
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
	
func _physics_process(delta):
	get_input()

	set_velocity(velocity)
	#set_up_direction(Vector2.ZERO)
	set_floor_stop_on_slope_enabled(false)
	move_and_slide()
	velocity = velocity

func play_stepSFX():
	AudioManager.play_random_pitch("step", 0.04, -12)
