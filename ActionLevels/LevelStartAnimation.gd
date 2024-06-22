extends CanvasLayer

onready var gradient_background_animation_player = get_node("%AnimationPlayerBackgroundGradient")
onready var level_name_3d_text = get_node("%LevelName3DText")
onready var level_title = get_node("%LevelTitle")

signal level_start_animation_finished

func _ready():
	self.visible = false
	
func level_start_animation():
	self.visible = true
	gradient_background_animation_player.play("color_gradient_1")

func _on_LevelTitle_visibility_changed():
	if level_title.visible:
		level_name_3d_text.start_spin()


func _on_AnimationPlayerBackgroundGradient_animation_finished(anim_name):
	self.emit_signal("level_start_animation_finished")
