extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite

export var movementSpeed = 10
export var gravityPower = 10
export var jumpPower = 20

export (PackedScene) var gunshot

# Private variables
var velocity = Vector2(0,0)
var movementVelocity = Vector2(0,0)
var gravity = 0
var doubleJump = false

func _ready():
	pass


func _process(delta):
	_animated_sprite.play("run")

	applyControls()
	applyGravity()

	velocity = velocity.linear_interpolate(movementVelocity * 10, delta * 15)
	move_and_slide(velocity + Vector2(0, gravity), Vector2(0,-1))

func applyControls():
	movementVelocity = Vector2(0,0)
	
	if Input.is_action_pressed("left"):
		movementVelocity.x = -movementSpeed
	elif Input.is_action_pressed("right"):
		movementVelocity.x = movementSpeed
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			jump(1)
			doubleJump = true
		elif doubleJump:
			jump(1)
			doubleJump = false
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func applyGravity():
	gravity += gravityPower
	
	if gravity > 0 and is_on_floor():
		gravity = 10
	
	if is_on_ceiling():
		gravity = 0

func jump(multiplier):
	gravity = -jumpPower * multiplier * 10
	
func shoot():
	var _gunshot = gunshot.instance()
	get_tree().get_root().add_child(_gunshot)
	_gunshot.direction = 1
	_gunshot.position = self.position + Vector2(200, 20)
	pass
	
