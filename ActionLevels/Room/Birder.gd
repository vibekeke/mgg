extends WindowDialog

onready var parent_node = self.get_parent()
onready var tweet_container = get_node("%TweetContainer")

const tweet_panel = preload("res://ActionLevels/Room/Tweet.tscn")
var tweet_path = "res://Conversations/tweets/"

func _on_Birder_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if parent_node != null:
				parent_node.move_child(self, parent_node.get_child_count())
			else:
				print_debug("That did not work dummy")

func create_tweet_panels(tweets):
	for tweet in tweets:
		var _instanced_tweet_panel = tweet_panel.instance()
		tweet_container.add_child(_instanced_tweet_panel)
		_instanced_tweet_panel.set_tweet_data(tweet)

func _ready():
	var loaded_tweets = load_tweets()
	create_tweet_panels(loaded_tweets)
	
func load_tweets():
	var loaded_tweets = File.new()
	if not loaded_tweets.file_exists(tweet_path + "misc/filler-1.json"):
		print_debug("Conversation not found.")
		return
	loaded_tweets.open(tweet_path + "misc/filler-1.json", File.READ)
	var dialog_data = JSON.parse(loaded_tweets.get_as_text())
	if typeof(dialog_data.result) == TYPE_ARRAY:
		return dialog_data.result
	print_debug("Failed to read dialog data!")
	return []
