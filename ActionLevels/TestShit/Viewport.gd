extends Viewport

onready var billboard_text = get_node("%BillboardText")
signal text_animation_finished
export var title_text = "LEVEL 1"

func _ready():
	billboard_text.visible = false
	billboard_text.connect("billboard_animation_finished", self, "_on_billboard_animation_finished")

func start_spin():
	billboard_text.visible = true
	billboard_text.start_spin_animation()

func _on_billboard_animation_finished():
	self.emit_signal("text_animation_finished")
	
func set_visibility(visibility: bool):
	billboard_text.visible = visibility
	
