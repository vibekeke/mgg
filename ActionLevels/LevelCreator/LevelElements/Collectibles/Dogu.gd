extends Node2D

export (float, 1, 1000) var amplitude := 5.0
export (float, 1, 1000) var frequency := 150.0
export (PackedScene) var dog_sprite
export (int) var scroll_speed
export (int) var y_init
export (int) var x_init

onready var area2d = $Area2D
var time = 0
var dog_breed

func _ready():
	var _dog_sprite = dog_sprite.instance()
	dog_breed = _dog_sprite.name
	_dog_sprite.set_name("DogSprite")
	area2d.add_child(_dog_sprite)
	area2d.connect("body_entered", self, "_on_call_body_entered")

func _increment_dogs():
	Events.emit_signal("collected_dog", self.dog_breed)

func _on_call_body_entered(body):
	if body.name == "Player":
		self.visible = false
		_increment_dogs()
		queue_free()

func _physics_process(delta):
	time += delta
	var movement = cos(time * frequency) * amplitude
	$Area2D/DogSprite.position.y += movement * delta
	self.position.x -= scroll_speed * delta
