extends Spatial

onready var spinny_text_animation_player = get_node("%SpinnyText")

signal billboard_animation_finished

func _ready():
	spinny_text_animation_player.play("spin")

func start_spin_animation():
	spinny_text_animation_player.play("spin")


func _on_SpinnyText_animation_finished(anim_name):
	if anim_name == "spin":
		self.emit_signal("billboard_animation_finished")
