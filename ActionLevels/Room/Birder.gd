extends WindowDialog

onready var parent_node = self.get_parent()

func _on_Birder_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if parent_node != null:
				parent_node.move_child(self, parent_node.get_child_count())
			else:
				print_debug("That did not work dummy")
