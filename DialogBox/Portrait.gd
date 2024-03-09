extends TextureRect

export var character_name := DataClasses.CharacterPortrait.None

onready var player_mg_portrait = get_node("%PlayerMG")
onready var player_normal_portrait = get_node("%PlayerNormal")
onready var angel_determined_portrait = get_node("%AngelDetermined")
onready var angel_happy_portrait = get_node("%AngelHappy")
onready var angel_intense_portrait = get_node("%AngelIntense")
onready var angel_neutral_portrait = get_node("%AngelNeutral")
onready var angel_sad_portrait = get_node("%AngelSad")
onready var angel_scared_portrait = get_node("%AngelScared")

var angel_background = load("res://imported_assets/dialog/portraits/Portrait_ANGEL_BG.png")
var player_background = load("res://imported_assets/dialog/portraits/Portrait_MG_BG.png")

onready var character_name_to_background = {
	DataClasses.CharacterPortrait.Player: player_background,
	DataClasses.CharacterPortrait.AngelDetermined: angel_background,
	DataClasses.CharacterPortrait.AngelHappy: angel_background,
	DataClasses.CharacterPortrait.AngelNeutral: angel_background,
	DataClasses.CharacterPortrait.AngelSad: angel_background,
	DataClasses.CharacterPortrait.AngelScared: angel_background,
	DataClasses.CharacterPortrait.AngelIntense: angel_background
}

onready var character_name_to_portraits = {
	DataClasses.CharacterPortrait.Player: player_normal_portrait,
	DataClasses.CharacterPortrait.MGPlayer: player_mg_portrait,
	DataClasses.CharacterPortrait.AngelDetermined: angel_determined_portrait,
	DataClasses.CharacterPortrait.AngelHappy: angel_happy_portrait,
	DataClasses.CharacterPortrait.AngelNeutral: angel_neutral_portrait,
	DataClasses.CharacterPortrait.AngelSad: angel_sad_portrait,
	DataClasses.CharacterPortrait.AngelScared: angel_scared_portrait,
	DataClasses.CharacterPortrait.AngelIntense: angel_intense_portrait,
}

func display_character(_character_name: int):
	self.character_name = _character_name
	load_character_texture()
	
func load_character_texture():
	print("loading ", self.character_name)
	for _character_name in character_name_to_portraits.keys():
		character_name_to_portraits[_character_name].visible = (_character_name == self.character_name)

func _ready():
	MggDialogue.connect("change_character_portrait", self, "_on_change_character_portrait")

func play_talk():
	pass

func _on_change_character_portrait(_character_name: int):
	display_character(_character_name)
