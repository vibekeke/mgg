extends Panel

#swaped these cause looks better blue as focused
var focused_theme : StyleBox = load("res://DialogBox/ResponseTemplateUnfocused.tres")
var unfocused_theme : StyleBox = load("res://DialogBox/ResponseTemplateFocused.tres")

onready var response_text = get_node("%Response")
onready var glow_animate = get_node("%GlowAnimate")

func set_text(text):
	response_text.bbcode_text = "[center]" + text + "[/center]"

func _ready():
	self.add_stylebox_override("panel", unfocused_theme)

func _on_ResponseTemplate_focus_entered():
	glow_animate.play("glow")
	self.add_stylebox_override("panel", focused_theme)

func _on_ResponseTemplate_focus_exited():
	glow_animate.stop(true)
	self.add_stylebox_override("panel", unfocused_theme)
