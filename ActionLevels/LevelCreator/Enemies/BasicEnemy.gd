extends Node2D


onready var death_explosion = preload("res://ActionLevels/LevelCreator/Enemies/EnemyAssets/AnimatedEnemyExplosion.tscn")

export(DataClasses.SpawnHeight) var spawn_height = DataClasses.SpawnHeight.ANY
export (Vector2) var custom_grounded_spawn_point

export (float) var initial_scroll_speed
export (int) var health_value = 1
export (PackedScene) var enemy_logic
export (bool) var is_boss = false
export (bool) var debug_mode = false
export (bool) var has_non_queue_free_rotator = false # hack to ensure rotator and children arent killed during queue free
export (Array, PackedScene) var droppables

onready var enemy_follower = $Path2D/PathFollow2D
onready var area2d = $Path2D/PathFollow2D/Area2D
onready var sprite = $Path2D/PathFollow2D/Area2D/AnimatedSprite
onready var collision_shape = $Path2D/PathFollow2D/Area2D/CollisionShape2D
onready var visibility_notifier = $Path2D/PathFollow2D/Area2D/VisibilityNotifier2D

onready var rng = RandomNumberGenerator.new()

var player_local_position = Vector2(0,0)
var player_global_position = Vector2(0,0)
var hit_times = 0
var is_move_disabled = false

var enemy_logic_instance = null
var has_invulnerability = false
var active_death_explosion_node = null

var damage_timer = Timer.new()
var eventually_queue_free_timer = Timer.new()

func _ready():
	rng.randomize()
	if enemy_logic != null:
		enemy_logic_instance = enemy_logic.instance()
		if "debug_mode" in enemy_logic_instance:
			enemy_logic_instance.debug_mode = self.debug_mode
		self.add_child(enemy_logic_instance)
	else:
		print("No logic found for enemy.")
	area2d.connect("area_entered", self, "_on_call_area_entered")
	area2d.connect("body_entered", self, "_on_call_body_entered")
	Events.connect("player_local_position", self, "_on_player_local_position")
	Events.connect("player_global_position", self, "_on_player_global_position")
	Events.connect("disable_enemy_action", self, "_on_disable_enemy_action")
	visibility_notifier.connect("screen_exited", self, "_on_screen_exited")
	enemy_spawn_point()
	_damage_timer_setup()
	_eventually_queue_free_setup()

func _eventually_queue_free_setup():
	eventually_queue_free_timer.set_name("eventually_queue_free_timer")
	eventually_queue_free_timer.connect("timeout", self, "_on_eventually_queue_free_timer")
	eventually_queue_free_timer.set_wait_time(5.0)
	self.add_child(eventually_queue_free_timer)

func _on_eventually_queue_free_timer():
	self.queue_free()

func _damage_timer_setup():
	damage_timer.set_name("damage_timer")
	damage_timer.connect("timeout", self, "_on_damage_timer")
	damage_timer.set_wait_time(0.2)
	self.add_child(damage_timer)

func _on_damage_timer():
	sprite.modulate = Color(1,1,1,1)
	damage_timer.stop()

func spawn_possible_collectible(death_position: Vector2):
	if rng.randi_range(0, 10) < 3 and droppables.size() > 0:
		var _collectible_to_spawn = droppables[randi() % droppables.size()].instance()
		_collectible_to_spawn.position = death_position
		get_tree().get_root().add_child(_collectible_to_spawn)


func call_death(count_as_regular_death: bool):
	if count_as_regular_death:
		Events.emit_signal("regular_enemy_death")
	if is_boss:
		Events.emit_signal("level_complete")
	if is_instance_valid(collision_shape):
		collision_shape.disabled = true
	if is_instance_valid(area2d):
		active_death_explosion_node = death_explosion.instance()
		active_death_explosion_node.add_to_group("death_explosion")
		var death_position = area2d.position
		var death_global_position = area2d.global_position
		active_death_explosion_node.position = death_position
		active_death_explosion_node.connect("animation_finished", self, "_on_explosion_finished")
		area2d.add_child(active_death_explosion_node)
		sprite.visible = false
		active_death_explosion_node.play("default", false)
		spawn_possible_collectible(death_global_position)

func _on_explosion_finished():
	if !has_non_queue_free_rotator:
		self.queue_free()
	else:
		eventually_queue_free_timer.start()

func _on_disable_enemy_action(is_disabled):
	is_move_disabled = !is_move_disabled

func _on_player_local_position(_player_local_position):
	self.player_local_position = _player_local_position

func _on_player_global_position(_player_global_position):
	self.player_global_position = _player_global_position

func take_damage(damage_value:= 1):
	damage_timer.start()
	sprite.modulate = Color(10,10,10,1)
	if !is_boss:
		self.position.x = self.position.x + 5 # slight knockback if not a boss
	health_value -= damage_value
	Events.emit_signal("enemy_taken_damage", self, health_value)
	if health_value <= 0:
		call_deferred("call_death", true)

func _on_call_body_entered(body):
	if body.name == 'Player':
		Events.emit_signal("collided_with_player", 1)
		if !has_invulnerability:
			take_damage()

func _on_call_area_entered(player_bullet):
	if player_bullet.get_parent() != null:
		var parent_groups = player_bullet.get_parent().get_groups()
		if "player_charge_shot" in parent_groups:
			if !has_invulnerability:
				hit_times += 1
				take_damage()
		elif "player_bullet" in parent_groups:
			if player_bullet.get_parent().belongs_to_player != null:
				if has_invulnerability:
					player_bullet.get_parent().queue_free()
				if !has_invulnerability:
					take_damage()
					player_bullet.get_parent().queue_free()

func enemy_spawn_point():
	if enemy_logic_instance != null:
		if enemy_logic_instance.has_method("get_spawn_height"):
			self.spawn_height = enemy_logic_instance.get_spawn_height()

func off_screen_call():
	Events.emit_signal("regular_enemy_death")
	queue_free()

func _on_screen_exited():
	queue_free()

func is_on_screen():
	return visibility_notifier.is_on_screen()

func _physics_process(delta):
	if self.global_position.x < 0 || self.global_position.y < 0:
		off_screen_call()

func get_enemy_name():
	return self.name
	
func get_non_queue_free_rotator():
	return has_non_queue_free_rotator

func set_non_queue_free_rotator(non_queue_free_rotator : bool):
	self.has_non_queue_free_rotator = non_queue_free_rotator
