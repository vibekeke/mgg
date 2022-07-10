extends Label

func _process(delta):
	var current_time = OS.get_time(false)
	var current_hour = str(current_time['hour'])
	var current_minute = str(current_time['minute'])
	if current_hour.length() < 2:
		current_hour = "0" + current_hour
	if current_minute.length() < 2:
		current_minute = "0" + current_minute
	self.text = current_hour + ":" + current_minute
