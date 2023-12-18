extends AudioStreamPlayer

export (Array, AudioStream) var audio_stream = []

var current_audio_index = 0

func _ready():
	if audio_stream.size() > 1:
		current_audio_index = 0
		self.stream = audio_stream[0]
	else:
		print("no elements in stream")
		
func play_by_index(index: int, music_position: float):
	self.stream = audio_stream[index]
	current_audio_index = index
	self.play(music_position)

func set_next_audio_track():
	var next_track_index = current_audio_index + 1
	if next_track_index <= (audio_stream.size() - 1):
		self.stream = audio_stream[next_track_index]
		current_audio_index = next_track_index
	else:
		self.stream = audio_stream[0]
		current_audio_index = 0

func get_current_index_audio_stream():
	return current_audio_index
	
func get_number_of_audio_streams():
	return audio_stream.size()
