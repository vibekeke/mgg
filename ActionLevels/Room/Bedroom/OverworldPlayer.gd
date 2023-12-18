extends KinematicBody2D

onready var animation_tree = get_node("%AnimationTree")
onready var overworld_reactions = get_node("%OverworldPlayerReactions")

var speed = 200
var velocity = Vector2.ZERO
var is_controlled = false

func _ready():
	Events.connect("overworld_player_controlled", self, "_on_overworld_player_controlled")

func _on_overworld_player_controlled(status):
	is_controlled = status

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
	if Input.is_action_pressed("right"):
		velocity.x += 1
	elif Input.is_action_pressed("left"):
		velocity.x -= 1
	elif Input.is_action_pressed("down"):
		velocity.y += 1
	elif Input.is_action_pressed("up"):
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

	velocity = move_and_slide(velocity, Vector2.ZERO, false)
