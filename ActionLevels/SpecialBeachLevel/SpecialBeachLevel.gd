extends Level

export var special_beach_dialogue : Resource

#I made the queue a bunch of tuples with the portraits cause it won't change the first portrait otherwise
var dialogue_queue = [
	["you_did_it", DataClasses.CharacterPortrait.AngelIntense],
	["true_completionist", DataClasses.CharacterPortrait.AngelHappy],
	["proud", DataClasses.CharacterPortrait.AngelHappy],
	["wow", DataClasses.CharacterPortrait.AngelHappy],
	["good_job", DataClasses.CharacterPortrait.AngelHappy],
	["dotdot", DataClasses.CharacterPortrait.AngelNeutral],
	["this_is_it", DataClasses.CharacterPortrait.AngelNeutral],
	["doesnt_matter", DataClasses.CharacterPortrait.AngelNeutral],
	["video_games", DataClasses.CharacterPortrait.AngelIntense],
	["greatest_honor", DataClasses.CharacterPortrait.AngelNeutral],
	["thanks", DataClasses.CharacterPortrait.AngelHappy],
	["thanksss", DataClasses.CharacterPortrait.AngelNeutral],
	["are_you_still_here", DataClasses.CharacterPortrait.AngelNeutral],
	["dotdotdot", DataClasses.CharacterPortrait.AngelNeutral],
	["for_real", DataClasses.CharacterPortrait.AngelNeutral],
	["for_real2", DataClasses.CharacterPortrait.AngelNeutral],
	["ok_fine",DataClasses.CharacterPortrait.AngelScared],
	["for_real3", DataClasses.CharacterPortrait.AngelIntense],
	["finish", DataClasses.CharacterPortrait.AngelHappy]
]

func _ready():
	randomize()
	Events.emit_signal("player_invincible", true)
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")


func _on_LevelStartDisplay_confirm_level_start():
	AudioManager.play_music("cafe")
	start_dialogue_timer()

func _on_dialogue_box_finished(node_id):
	if self.get_instance_id() == node_id:
		start_dialogue_timer()

func start_dialogue_timer():
	var time = rand_range(1, 3)
	$"%DialogueTimer".wait_time = time
	$"%DialogueTimer".start()

func _on_DialogueTimer_timeout():
	play_next_dialogue()

func play_next_dialogue():
	var elem = _get_next_dialogue()
	if elem == null or typeof(elem) != TYPE_ARRAY or elem.size() != 2:
		return
	
	var dialogue_name = elem[0]
	var portrait = elem[1]
	
	MggDialogue.create_dialogue_balloon(
		dialogue_name, 
		special_beach_dialogue, 
		self.get_instance_id(), 
		DataClasses.Placement.UPPER, 
		portrait,
		Color(0.0, 0.38, 0.58, 0.6),
		Color(0.0, 0.0, 0.0, 0.25),
		true,
		1.5
	)

func _get_next_dialogue():
	if dialogue_queue.size() > 0:
		return dialogue_queue.pop_front()
	return null   # or null if you prefer
