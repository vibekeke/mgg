extends AnimatedSprite

onready var tv_area = get_node("%TVArea2D")
onready var tv_audio = get_node("%TVAudio")
export (NodePath) var tv_screen
onready var tv_screen_node = get_node(tv_screen)

var player_in_area = false
func _ready():
	tv_area.connect("body_entered", self, "_on_tv_area_entered")
	tv_area.connect("body_exited", self, "_on_tv_area_exited")
	
func _on_tv_area_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true

func screen_state(state):
	get_node(tv_screen).visible = state

func _on_tv_area_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		if !tv_screen_node.visible:
			tv_screen_node.visible = true
			tv_audio.play()
		else:
			tv_screen_node.visible = false
			tv_audio.stop()
