extends CanvasLayer


var is_visible = false
var ascend_unlocked = false

onready var line_no_float = get_node("%NoFloatLine")
onready var line_no_damage = get_node("%NoDamageLine")
onready var line_pacifist = get_node("%PacifistLine")
onready var line_high_score = get_node("%HighScoreLine")
onready var ascend_button = get_node("%AscendButton")

var level_challenges = {
	'Level1': {'no_float': false, 'no_damage': false, 'pacifist': false, 'high_score': false}
}

func _ready():
	check_completed_challenges()
	
	line_no_float.visible   = level_challenges["Level1"]["no_float"]
	line_no_damage.visible  = level_challenges["Level1"]["no_damage"]
	line_pacifist.visible   = level_challenges["Level1"]["pacifist"]
	line_high_score.visible = level_challenges["Level1"]["high_score"]

	ascend_unlocked = not level_challenges["Level1"].values().has(false)
	if ascend_unlocked:
		ascend_button.visible = true
		$ButtonAnimationPlayer.play("button_bob")
	else:
		ascend_button.visible = false

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
	level_challenges['Level1']['no_float'] = StatsTracker.no_float_run_completed
	level_challenges['Level1']['no_damage'] = StatsTracker.no_damage_taken_run_completed
	level_challenges['Level1']['pacifist'] = StatsTracker.pacifist_run_completed
	level_challenges['Level1']['high_score'] = StatsTracker.high_score_run_completed

func _on_PaperArea_open_challenge_menu():
	toggle_visible()
