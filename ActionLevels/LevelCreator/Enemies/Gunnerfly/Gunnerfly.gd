extends Node

class_name Gunnerfly

export(PackedScene) var gunshot_gunnerfly
onready var parent_node = self.get_parent()
enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var _timer = Timer.new()
var default_shooting_angle = SHOOT_ANGLE.FORWARD_B
export var shot_time_seconds = 1.3

# how fast to flash
export var flash_time_seconds = 0.07

var _flash_timer = Timer.new()
var is_flashing = false

var charging_shot_params = {
	'flash_modifier': 0.7
}

func _ready():
	parent_node.add_child(_timer)
	_timer.connect("timeout", self, "_shoot")
	_timer.set_wait_time(shot_time_seconds)
	_timer.set_one_shot(false)
	_timer.start()

	_flash_timer.connect("timeout", self, "_flash_shader_with_timer")
	_flash_timer.set_wait_time(flash_time_seconds)
	_flash_timer.set_one_shot(false)
	parent_node.add_child(_flash_timer)


func _shoot():
	if gunshot_gunnerfly != null and parent_node.is_on_screen():
		var _gunshot = gunshot_gunnerfly.instance()
		_gunshot.belongs_to_player = false
		_gunshot.move_rightward = false
		_gunshot.set_bullet_type(default_shooting_angle)
		get_tree().get_root().add_child(_gunshot)
		_gunshot.position = parent_node.position + Vector2(-76,3)

func start_flashing():
	if !is_flashing:
		is_flashing = true
		_flash_timer.start()

func _flash_shader_with_timer():
	var flash_value = parent_node.get_node("%AnimatedSprite").material.get_shader_param('flash_modifier')
	if flash_value <= 0.0:
		parent_node.get_node("%AnimatedSprite").material.set_shader_param('flash_modifier', 0.5)
	else:
		parent_node.get_node("%AnimatedSprite").material.set_shader_param('flash_modifier', 0.0)


func _process(delta):
	if _timer.time_left <= 0.3:
		start_flashing()
		#parent_node.get_node("%AnimatedSprite").material.set_shader_param('flash_modifier', 0.7)
	else:
		is_flashing = false
		parent_node.get_node("%AnimatedSprite").material.set_shader_param('flash_modifier', 0.0)

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "Gunnerfly"
