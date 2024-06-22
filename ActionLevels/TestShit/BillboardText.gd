extends Spatial

onready var spinny_text_animation_player = get_node("%SpinnyText")
onready var title_text = get_node("%TitleText")

signal billboard_animation_finished

func _ready():
	spinny_text_animation_player.play("spin")

func start_spin_animation():
	spinny_text_animation_player.play("spin")

func set_text(text_string: String):
	title_text.mesh.text = text_string
	

func _on_SpinnyText_animation_finished(anim_name):
	if anim_name == "spin":
		self.emit_signal("billboard_animation_finished")
