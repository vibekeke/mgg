extends Sprite

onready var piano_music = get_node("%PianoMusic")

var player_in_area : bool = false

func _on_Area2D_body_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true

func _on_Area2D_body_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func start_music():
	Events.emit_signal("overworld_player_controlled", true)
	piano_music.play()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player_in_area and !piano_music.playing:
		start_music()

func _on_PianoMusic_finished():
	Events.emit_signal("overworld_player_controlled", false)
	piano_music.set_next_audio_track()
