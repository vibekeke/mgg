extends PanelContainer

onready var profile_name = get_node("%Name")
onready var profile_tag = get_node("%Tag")
onready var tweet_text = get_node("%TweetText")
onready var profile_pic = get_node("%BirderProfPic")
onready var tweet_image = get_node("%TweetImage")
onready var tweet_image_container = get_node("%OptionalImageContainer")

onready var number_replies = get_node("%NumberMessages")
onready var number_retweets = get_node("%NumberRetweet")
onready var number_likes = get_node("%NumberLike")

onready var retweet_icon = get_node("%RetweetIcon")
onready var reply_icon = get_node("%ReplyIcon")
onready var heart_icon = get_node("%HeartIcon")

onready var retweet_button = get_node("%RetweetButton")
onready var reply_button = get_node("%MessageButton")
onready var heart_button = get_node("%LikeButton")

var profile_pic_path = "res://ActionLevels/Room/BirderAssets/"

var default_res_font_titles_size = 32
var default_res_font_small_size = 0

onready var meta_name_to_texture_map = {
	'redHog': 'res://ActionLevels/Room/BirderAssets/hedgehog-profile.png',
	'literallyVibekesDad': 'res://ActionLevels/Room/BirderAssets/dadpower.png',
	'partySnake': 'res://ActionLevels/Room/BirderAssets/partysnake.png',
	'skjeggy': 'res://ActionLevels/Room/BirderAssets/skjeggy.png'
}

func _ready():
	if OS.get_window_size().y < 1080:
		var scaling_ratio = 1080.0 / float(OS.get_window_size().y)

		# body text
		var font = tweet_text.get_font("font")
		font.size = default_res_font_titles_size * scaling_ratio
		print("new font size", font.size)
		tweet_text.add_font_override("font", font)
		
		# name
		profile_name.add_font_override("font", font)		
		# tag
		profile_tag.add_font_override("font", font)
	
		# stats
		number_likes.add_font_override("font", font)
		number_replies.add_font_override("font", font)
		number_retweets.add_font_override("font", font)

		scale_icon_buttons(scaling_ratio, reply_button)
		scale_icon_buttons(scaling_ratio, retweet_button)
		scale_icon_buttons(scaling_ratio, heart_button)

		scale_icons(scaling_ratio, heart_icon)
		scale_icons(scaling_ratio, retweet_icon)
		scale_icons(scaling_ratio, reply_icon)

		scale_profile_pic(scaling_ratio, profile_pic)
		
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	number_replies.text = String(rng.randi_range(1, 5000))
	number_retweets.text = String(rng.randi_range(1, 5000))
	number_likes.text = String(rng.randi_range(1, 5000))

func scale_profile_pic(scaling_ratio, prof_pic):
	prof_pic.rect_min_size.x = rect_min_size.x + 30
	prof_pic.rect_min_size.y = rect_min_size.y + 30
	prof_pic.rect_size.y = rect_min_size.y + 30
	prof_pic.rect_size.y = rect_min_size.y + 30
	# prof_pic.rect_scale = Vector2(scaling_ratio, scaling_ratio)

func scale_icons(scaling_ratio, icon):
	icon.rect_scale = Vector2(scaling_ratio, scaling_ratio)

func scale_icon_buttons(scaling_ratio, button):
	button.rect_min_size.x = 30 * scaling_ratio 
	button.rect_min_size.y = 30 * scaling_ratio 
	button.rect_size.x = 30 * scaling_ratio 
	button.rect_size.y = 30 * scaling_ratio 

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
