extends PanelContainer

onready var profile_name = get_node("%Name")
onready var profile_tag = get_node("%Tag")
onready var tweet_text = get_node("%TweetText")

func set_profile_pic(name_for_profile_pic):
	pass

func set_tweet_data(tweet_data):
	profile_name.set_text(tweet_data['name'])
	profile_tag.set_text("@" + tweet_data['tag'])
	tweet_text.set_text(tweet_data['content'])
	set_profile_pic(tweet_data['name'])
