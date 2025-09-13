extends CanvasLayer


var is_visible = false
var ascend_unlocked = false

onready var ascend_button = get_node("%AscendButton")

var level_challenges = {
	'Level1': {'no_float': false, 'no_damage': false, 'pacifist': false, 'high_score': false}
}

func _ready():
	check_completed_challenges()
	if ascend_unlocked: 
		ascend_button.visible = true

func toggle_visible():
	if is_visible:
		$AnimationPlayer.play("fade_out")
	else:
		$AnimationPlayer.play("fade_in")
		AudioManager.play_random_pitch("paper_rustle")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		is_visible = false
		Events.emit_signal("overworld_player_controlled", false)
	elif anim_name == "fade_in":
		is_visible = true

func check_completed_challenges():
	level_challenges['Level1']['no_float'] = StatsTracker.no_float_run()
	level_challenges['Level1']['no_damage'] = StatsTracker.no_damage_taken()
	level_challenges['Level1']['pacifist'] = StatsTracker.full_pacifist()
	level_challenges['Level1']['high_score'] = StatsTracker.high_score_over_threshold()
	print("level challenges ", level_challenges)

func _on_PaperArea_open_challenge_menu():
	toggle_visible()
