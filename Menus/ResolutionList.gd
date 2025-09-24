extends ItemList

func _on_ResolutionList_item_activated(index):
	match index:
		0:
			if get_window().get_size() != Vector2(1920, 1080):
				get_window().set_size(Vector2(1920, 1080))
		1:
			if get_window().get_size() != Vector2(1280, 720):
				get_window().set_size(Vector2(1280, 720))
		2:
			var os_screen_res = DisplayServer.screen_get_size()
			get_window().set_size(os_screen_res)
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
		3:
			pass
		_:
			print("do nothing")
	
	
