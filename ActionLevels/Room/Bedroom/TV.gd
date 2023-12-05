extends AnimatedSprite

onready var tv_area = get_node("%TVArea2D")
onready var tv_audio = get_node("%TVAudio")

var player_in_area = false
func _ready():
	tv_area.connect("body_entered", self, "_on_tv_area_entered")
	tv_area.connect("body_exited", self, "_on_tv_area_exited")
	
func _on_tv_area_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true

	
func _on_tv_area_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		print("ye")
		if self.frame == 0:
			self.frame = 1
			tv_audio.play()
		elif self.frame == 1:
			self.frame = 0
			tv_audio.stop()
