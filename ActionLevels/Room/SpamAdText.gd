extends RichTextLabel

func _ready():
	pass


func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
  
export (float) var scroll_speed = 300

func _process(delta):
	pass
#	rect_position.x -= scroll_speed * delta
#	if rect_position.x < -rect_size.x:
#		rect_position.x = get_parent().get_rect().size.x
