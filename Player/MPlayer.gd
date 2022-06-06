extends KinematicBody2D

onready var _animation_player = $AnimationPlayer

export var movementSpeed = 100
export var gravityPower = 30
export var jumpPower = 100

# Private variables
var velocity = Vector2(0,0)
var movementVelocity = Vector2(0,0)
var gravity = 0
var doubleJump = false

var debug_stats = {
	"movementSpeed": movementSpeed,
	"gravityPower": gravityPower,
	"jumpPower": jumpPower
}

export (PackedScene) var gunshot

# Signals
signal debug_data

func _ready():
	print("Creating mplayer...")
	
func _process(delta):

	_animation_player.play("run")

	applyControls()
	applyGravity()

	velocity = velocity.linear_interpolate(movementVelocity * 10, delta * 15)
	move_and_slide(velocity + Vector2(0, gravity), Vector2(0,-1))
	
	if OS.is_debug_build():
		_on_Player_debug_data()

func applyControls():
	movementVelocity = Vector2(0,0)
	
	if Input.is_action_pressed("left"):
		movementVelocity.x = -movementSpeed
	elif Input.is_action_pressed("right"):
		movementVelocity.x = movementSpeed
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump(1)
			doubleJump = true
		elif doubleJump:
			jump(1)
			doubleJump = false
	
	if Input.is_action_just_pressed("shoot") && !Input.is_action_pressed("hold_test"):
		shoot()
	elif Input.is_action_just_pressed("shoot") && Input.is_action_pressed("hold_test"):
		shoot_diagonal()


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
	_gunshot.position = self.position + Vector2(80,2)

func shoot_diagonal():
	print("shooting diagonal")
	var _gunshot = gunshot.instance()
	_gunshot.position = self.position + Vector2(80,2)
	_gunshot.set_rotation_degrees(45.0)
	get_tree().get_root().add_child(_gunshot)

func _on_Player_debug_data():
	emit_signal("debug_data", debug_stats)
