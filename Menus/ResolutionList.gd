extends ItemList

func _on_ResolutionList_item_activated(index):
	match index:
		0:
			if OS.get_window_size() != Vector2(1920, 1080):
				OS.set_window_size(Vector2(1920, 1080))
		1:
			if OS.get_window_size() != Vector2(1280, 720):
				OS.set_window_size(Vector2(1280, 720))
		2:
			var os_screen_res = OS.get_screen_size()
			OS.set_window_size(os_screen_res)
			OS.window_fullscreen = !OS.window_fullscreen
		_:
			print("do nothing")
	
	
