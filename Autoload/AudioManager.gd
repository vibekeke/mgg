extends Node

var voices := 15
var sound_effects = {
	"GunShot" : preload("res://sounds/gunnerfly/Laser-weapon 2 - Sound effects Pack 2.wav")
}
var music = {}

var sfx_players = []
var next = 0
var sfx_bus = "SFX"

var music_player
var music_bus = "Music"
var fade_tween = null

func _ready():
	randomize()
	#Default to master if they can't find the bus
	if AudioServer.get_bus_index(sfx_bus) == -1:
		sfx_bus = "Master"
	if AudioServer.get_bus_index(music_bus) == -1:
		music_bus = "Master"
	
	#SFX players
	for i in range(voices):
		var player = AudioStreamPlayer.new()
		player.bus = sfx_bus
		add_child(player)
		sfx_players.append(player)
	
	#Single Music player (Can add one more if we want overlapping transitions or whatever)
	music_player = AudioStreamPlayer.new()
	music_player.bus = music_bus
	add_child(music_player)
	
func playSFX(sound_effect : String, volume_db := 0.0, pitch_scale := 1.0) -> void:
	var sfx = sound_effects[sound_effect]
	if sfx == null:
		print("AudioManager: Couldn't find requested sound effect, ", sound_effect)
		return
	
	var sfx_player = sfx_players[next] 
	next = (next + 1) % sfx_players.size()
	sfx_player.stop()
	sfx_player.stream = sfx
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()

func play_random_pitch(sound_effect : String, volume_db := 0.0, spread := 0.04) -> void:
	var pitch = 1.0 + rand_range(-spread, spread)
	playSFX(sound_effect, volume_db, pitch)

func stop_all_sfx() -> void:
	for sfx_player in sfx_players: sfx_player.stop()


### MUSIC STUFF ###
#IDK how the music has previously been implemented, but we can have cool fade in and out logic here.
#I'm just gonna not do that for now, because it seems to work fine as is.
func play_music(track : String, volume_db := 0.0):
	var song = music[track]
	if song == null:
		return
	
	music_player.stop()
	music_player.stream = song
	music_player.volume_db = volume_db
	music_player.play()

func stop_music() -> void:
	if music_player and music_player.playing: music_player.stop()
