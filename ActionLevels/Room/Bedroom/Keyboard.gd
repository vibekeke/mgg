extends Sprite

onready var piano_music = get_node("%PianoMusic")
onready var can_create_dialogue = get_node("%CanCreateDialogue")

export var dialogue_resource: Resource
export var dialogue_title := "bedroom_piano"

var player_in_area : bool = false
var dialogue_over : bool = false

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
	if Input.is_action_just_pressed("ui_accept") and player_in_area and !piano_music.playing and !can_create_dialogue.dialogue_open:
		start_music()

func _on_PianoMusic_finished():
	if piano_music.get_number_of_audio_streams() - 1 == piano_music.get_current_index_audio_stream():
		can_create_dialogue.display_dialogue()
	Events.emit_signal("overworld_player_controlled", false)
	piano_music.set_next_audio_track()
