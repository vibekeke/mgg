extends CanvasLayer

func _ready():
	var player = null
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null:
		var level = main.get_node_or_null("Level1")
		if level != null:
			player = level.get_node_or_null("MPlayer")
	if player != null:
		player.connect("debug_data", self, "player_debug_handler")
	pass

func _process(delta):
	$VBoxContainer/Framerate.text = "FPS: " + str(Engine.get_frames_per_second())
	$VBoxContainer/MemoryUsage.text = "Static Mem: " + str(Performance.MEMORY_STATIC)
	$VBoxContainer/Objects.text = "Objects: " + str(Performance.OBJECT_NODE_COUNT)

func player_debug_handler(debug_data):
	if debug_data.has("movementSpeed"):
		$VBoxContainer/PlayerSpeed.text = "Speed: " + str(debug_data.get("movementSpeed"))
	if debug_data.has("shootAngle"):
		$VBoxContainer/ShootAngle.text = "Shoot Angle: " + str(debug_data.get("shootAngle"))
