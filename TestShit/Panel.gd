extends Panel

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
  
# On the child (Label)
export (float) var scroll_speed = 300

func _process(delta):
	rect_position.x -= scroll_speed * delta
	if rect_position.x < -rect_size.x:
		rect_position.x = get_parent().get_rect().size.x
