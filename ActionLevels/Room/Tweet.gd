extends PanelContainer

onready var profile_name = get_node("%Name")
onready var profile_tag = get_node("%Tag")
onready var tweet_text = get_node("%TweetText")
onready var profile_pic = get_node("%BirderProfPic")
onready var tweet_image = get_node("%TweetImage")
onready var tweet_image_container = get_node("%OptionalImageContainer")

var profile_pic_path = "res://ActionLevels/Room/BirderAssets/"

onready var meta_name_to_texture_map = {
	'redHog': 'res://ActionLevels/Room/BirderAssets/hedgehog-profile.png',
	'literallyVibekesDad': 'res://ActionLevels/Room/BirderAssets/dadpower.png',
	'partySnake': 'res://ActionLevels/Room/BirderAssets/partysnake.png',
	'skjeggy': 'res://ActionLevels/Room/BirderAssets/skjeggy.png'
}

func set_tweet_image(tweet_image_path):
	tweet_image.texture = load(tweet_image_path)

func set_profile_pic(meta_name_for_tweeter):
	profile_pic.set_profile_pic(meta_name_to_texture_map[meta_name_for_tweeter])

func set_tweet_data(tweet_data):
	profile_name.set_text(tweet_data['name'])
	profile_tag.set_text("@" + tweet_data['tag'])
	tweet_text.set_text(tweet_data['content'])
	set_profile_pic(tweet_data['metaName'])
	if tweet_data['image'] != "":
		set_tweet_image(tweet_data['image'])
	else:
		tweet_image_container.visible = false
