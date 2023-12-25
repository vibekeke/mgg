extends Control

func _ready():
#	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1280, 720))
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1280, 720))
	$ViewportContainer/Viewport.set_size_override(true, Vector2(1920, 1080))
	if $ViewportContainer/Viewport/WindowDialog.visible == false:
		$ViewportContainer/Viewport/WindowDialog.visible = true


func _on_Button_button_up():
	print("oi")
