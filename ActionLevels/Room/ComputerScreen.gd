extends Control


func _ready():
	#pass
	$BSN.popup_centered()
	$BSN.get_close_button().focus_mode = FOCUS_NONE
