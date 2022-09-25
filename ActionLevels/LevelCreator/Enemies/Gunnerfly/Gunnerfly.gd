extends Node

class_name Gunnerfly

export(PackedScene) var gunshot_gunnerfly
onready var parent_node = self.get_parent()
enum SHOOT_ANGLE { FORWARD_B, UPWARD_B, DOWNWARD_B }

var default_shooting_angle = SHOOT_ANGLE.FORWARD_B
var shot_time_seconds = 1.5
# action performed in physics_process, takes enemy node

func _ready():
	var _timer = Timer.new()
	parent_node.add_child(_timer)
	_timer.connect("timeout", self, "_shoot")
	_timer.set_wait_time(shot_time_seconds)
	_timer.set_one_shot(false)
	_timer.start()

func _shoot():
	if gunshot_gunnerfly != null and parent_node.is_on_screen():
		#for value in SHOOT_ANGLE.values():
		var _gunshot = gunshot_gunnerfly.instance()
		_gunshot.belongs_to_player = false
		_gunshot.move_rightward = false
		_gunshot.set_bullet_type(default_shooting_angle)
			#_gunshot.set_bullet_type(value)
		get_tree().get_root().add_child(_gunshot)
		_gunshot.position = parent_node.position + Vector2(-76,3)

func _physics_process(delta):
	if !parent_node.is_move_disabled:
		parent_node.position.x -= parent_node.initial_scroll_speed * 1.25 * delta

func get_class():
	return "Gunnerfly"
