extends Sprite

onready var close_icon = get_node("%CloseIcon")

func _ready():
	pass


func _on_CloseIconArea2D_mouse_entered():
	pass # Replace with function body.


func _on_CloseIconArea2D_mouse_exited():
	pass # Replace with function body.

func hide_window():
	self.visible = false

func _on_CloseIconArea2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouseleft") && self.visible:
		hide_window()
