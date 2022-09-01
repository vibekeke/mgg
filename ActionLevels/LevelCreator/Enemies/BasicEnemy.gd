extends Node2D

onready var death_explosion = preload("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/AnimatedEnemyExplosion.tscn")

export (float) var initial_speed
export (float) var initial_scroll_speed
export (float) var has_shot_timeout_seconds = 1.5
export (PackedScene) var gunshot

onready var enemy_follower = $Path2D/PathFollow2D
onready var area2d = $Path2D/PathFollow2D/Area2D
onready var sprite = $Path2D/PathFollow2D/Area2D/AnimatedSprite
onready var collision_shape = $Path2D/PathFollow2D/Area2D/CollisionShape2D

var player_local_position = Vector2(0,0)
var player_global_position = Vector2(0,0)

var is_move_disabled = false

enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var default_shooting_angle = SHOOT_ANGLE.FORWARD_B

func _ready():
	area2d.connect("area_entered", self, "_on_call_area_entered")
	area2d.connect("body_entered", self, "_on_call_body_entered")
	Events.connect("player_local_position", self, "_on_player_local_position")
	Events.connect("player_global_position", self, "_on_player_global_position")
	Events.connect("disable_enemy_action", self, "_on_disable_enemy_action")
	if "Gunnerfly" in self.name:
		var _timer = Timer.new()
		add_child(_timer)
		_timer.connect("timeout", self, "_shoot")
		_timer.set_wait_time(has_shot_timeout_seconds)
		_timer.set_one_shot(false)
		_timer.start()
	
func call_death():
	collision_shape.disabled = true
	var death_explosion_node = death_explosion.instance()
	death_explosion_node.position = area2d.position
	death_explosion_node.connect("animation_finished", self, "_on_explosion_finished")
	area2d.add_child(death_explosion_node)
	sprite.visible = false
	death_explosion_node.play("default", false)


func _on_explosion_finished():
	queue_free()

func _on_disable_enemy_action(is_disabled):
	print("i kneel.")
	is_move_disabled = !is_move_disabled

func _on_player_local_position(_player_local_position):
	self.player_local_position = _player_local_position

func _on_player_global_position(_player_global_position):
	self.player_global_position = _player_global_position

func _on_call_body_entered(body):
	if body.name == 'MPlayerTest':
		Events.emit_signal("collided_with_player", 1)
		call_deferred("call_death")

func _on_call_area_entered(area):
	if area.name == "GunshotArea2D":
		call_deferred("call_death")

func off_screen_call():
	queue_free()

func _shoot():
	if gunshot != null:
		if "Gunnerfly" in self.name:
			for value in SHOOT_ANGLE.values():
				var _gunshot = gunshot.instance()
				_gunshot.set_bullet_type(value)
				get_tree().get_root().add_child(_gunshot)
				_gunshot.position = self.position + Vector2(-76,3)
	else:
		print("gunshot is null, sure you meant to call this for this enemy?")

func _physics_process(delta):
	if self.global_position.x < 0 || self.global_position.y < 0:
		print('ded.')
		off_screen_call()
	if !is_move_disabled:
		enemy_follower.offset += initial_speed * delta
		if "Gunnerfly" in self.name:
			self.position.x -= initial_scroll_speed * 1.25 * delta
			self.position.y
		if "Misbeehave" in self.name:
			print('movin')
			if self.player_local_position != Vector2(0,0):
				if self.position.x - self.player_local_position.x > 0:
					self.position = self.position.move_toward(self.player_local_position, initial_scroll_speed * delta)
				else:
					self.position.x -= initial_scroll_speed * 1.25 * delta
		else:
			self.position.x -= initial_scroll_speed * delta
