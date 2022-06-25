extends Control


func _ready():
	$WindowDialog.popup_centered()
	$WindowDialog.get_close_button().focus_mode = FOCUS_NONE
