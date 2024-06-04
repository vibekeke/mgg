extends CanvasLayer

onready var gradient_background_animation_player = get_node("%AnimationPlayerBackgroundGradient")
onready var stars_animation_player = get_node("%AnimationPlayerStars")
onready var viewport = get_node("%Viewport")
onready var level_title = get_node("%LevelTitle")

signal level_start_animation_finished

var animation_one_finished = false
var animation_two_finished = false

func _ready():
	self.visible = false
	level_start_animation()
	
func level_start_animation():
	self.visible = true
	gradient_background_animation_player.play("color_gradient_1")
	stars_animation_player.play("stars")

func _on_LevelTitle_visibility_changed():
	if level_title.visible:
		viewport.start_spin()


func _on_AnimationPlayerBackgroundGradient_animation_finished(anim_name):
	animation_one_finished = true
	if animation_two_finished == true:
		self.emit_signal("level_start_animation_finished")


func _on_AnimationPlayerStars_animation_finished(anim_name):
	animation_two_finished = true
	if animation_one_finished:
		self.emit_signal("level_start_animation_finished")
