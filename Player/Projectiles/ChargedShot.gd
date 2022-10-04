extends AnimatedSprite

export var belongs_to_player = true

onready var collision_shape_extends = {
	0: Vector2.ZERO,
	1: Vector2.ZERO,
	2: Vector2.ZERO,
	3: Vector2.ZERO,
	4: Vector2(1069, 22),
	5: Vector2(1069, 85),
	6: Vector2(1069, 85),
	7: Vector2(1069, 85),
	8: Vector2(1069, 85),
	9: Vector2(1069, 85),
	10: Vector2(1069, 85),
	11: Vector2(1069, 17),
	12: Vector2.ZERO,
	13: Vector2.ZERO,
	14: Vector2.ZERO,
	15: Vector2.ZERO
}

func _ready():
	self.playing = true


func expand_collision_shape(frame: int):
	var new_collision_shape_extent = collision_shape_extends[frame]
	$Area2D/CollisionShape2D.shape.extents = new_collision_shape_extent
		
func _physics_process(delta):
	expand_collision_shape(self.frame)


func _on_ChargedShot_animation_finished():
	self.queue_free()
