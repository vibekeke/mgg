extends Node

var voices := 15
var sound_effects = {
	"ui_hover" : preload("res://sounds/UI sounds/zapsplat_menu_item_select001.wav"),
	"ui_confirm" : preload("res://sounds/UI sounds/vgmenuselect.wav"),
	"ui_confirm2" : preload("res://sounds/level/selection_confirm.wav"),
	"ui_pop_in" : preload("res://sounds/computer/maximize_008.wav"),
	"twinkle" : preload("res://sounds/UI sounds/twinkle_glissando.wav"),
	"jingle" : preload("res://sounds/UI sounds/starting_jingle.wav"),
	"mouse_click" : preload("res://sounds/mouseclick-cut.mp3"),
	"magic_sound" : preload("res://sounds/player/magic_sound_1.wav"),
	"player_shoot" : preload("res://sounds/player/zapsplat_simple_zap.wav"),
	"jump" : preload("res://sounds/player/zapsplat_short_retro_jump5.wav"),
	"slide" : preload("res://sounds/player/zs_slide0,6s.wav"),
	"charge_complete" : preload("res://sounds/player/1up 4 - Sound effects Pack 2.wav"),
	"charge_attack" : preload("res://sounds/player/laser_beam_tractor_3,0sec.wav"),
	"collect_heart" : preload("res://sounds/collecting/zapsplat_collect_bright_simple_mild.wav"),
	"collect_star" : preload("res://sounds/collecting/zaplsplat_retro_simple_bright.wav"),
	"explosion" : preload("res://sounds/damage/zapsplat_bubblepop_designed.wav"),
	"player_damage" : preload("res://sounds/damage/Laser-weapon 8 - Sound effects Pack 2.wav"),
	"gunshot" : preload("res://sounds/gunnerfly/handgun 9mm silenced.wav"),#ty pls implement
	"gun_reload" : preload("res://sounds/gunnerfly/shotgun_reload.wav"),	#idk, it was in the files lol
	"our_guy" : preload("res://sounds/enemy attacks/WHYAREYOURUNNING.wav"),	#ty pls implement
	"small_win" : preload("res://sounds/level/zapsplat_multimedia_game_sound_win_award_bonus_complete_collect_special_item_109030.mp3"),
	"you_win" : preload("res://sounds/level/you win.ogg"),
	"dialogue": preload("res://sounds/dialogue/beep.wav")
	
	#See sounds/enemy attacks for many cool lasery enemy attack sounds!
	#Idk how the fuck enemies work and I can't figure it out, so I'll leave it to you to add sounds for
	## running guy, see above
	## gunshot & reload(?), see above
	## the UFO guys, see sounds/enemy
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
	pause_mode = Node.PAUSE_MODE_PROCESS
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
	
func playSFX(sound_effect : String, pitch_scale := 1.0, volume_db := 0.0) -> void:
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

func play_random_pitch(sound_effect : String, spread := 0.04, volume_db := 0.0) -> void:
	var pitch = 1.0 + rand_range(-spread, spread)
	playSFX(sound_effect, pitch, volume_db)

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
