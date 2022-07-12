extends Panel

func _ready():
#	var new_dialog = Dialogic.start('ayylmao_firstchat')
#	$ChatBody.add_child(new_dialog)
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("down"):
		print("doon pressed")
