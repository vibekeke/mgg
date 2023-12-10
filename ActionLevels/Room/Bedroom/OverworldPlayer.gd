extends KinematicBody2D

var speed = 200
var velocity = Vector2.ZERO
var is_controlled = false

func _ready():
	pass

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
	
func _physics_process(delta):
	get_input()

	velocity = move_and_slide(velocity, Vector2.ZERO, false)
