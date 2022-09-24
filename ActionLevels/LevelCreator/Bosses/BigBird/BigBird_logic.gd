extends Node

class_name BigBird

export(PackedScene) var lil_bird_bullet
export(float) var fire_rate_secs := 0.1
export(int) var projectile_speed := 750
onready var parent_node = self.get_parent()
onready var fire_rate_timer = Timer.new()
onready var bullet_paths = get_tree().get_nodes_in_group("bullet_paths")

func _ready():
	_fire_rate_timer_setup()
				
func _fire_rate_timer_setup():
	fire_rate_timer.set_name("boss_fire_rate_timer")
	fire_rate_timer.connect("timeout", self, "_on_fire_rate_timeout")
	fire_rate_timer.set_wait_time(fire_rate_secs)
	parent_node.add_child(fire_rate_timer)

func _on_fire_rate_timeout():
	fire_rate_timer.stop()

func _spawn_bullet():
	for path in bullet_paths:
		var _lil_bird_bullet = lil_bird_bullet.instance()
		_lil_bird_bullet.set_speed(projectile_speed)
		path.add_child(_lil_bird_bullet)
	fire_rate_timer.start()

func _process(delta):
	if fire_rate_timer.is_stopped():
		_spawn_bullet()

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "BigBird"
