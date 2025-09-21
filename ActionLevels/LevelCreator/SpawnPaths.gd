extends Path2D


func get_spawn_points():
	var num_spawn_points = self.get_curve().get_point_count()
	var spawn_point_dictionary = {}
	var spawn_point_heights = [DataClasses.SpawnHeight.HIGH_ONLY, DataClasses.SpawnHeight.MED_ONLY, DataClasses.SpawnHeight.LOW_ONLY]
	var spawn_point_array = []
	for x in range(0, num_spawn_points):
		var local_pos = self.get_curve().get_point_position(x)
		var global_pos = self.to_global(local_pos)
		spawn_point_array.append(global_pos)
		spawn_point_dictionary[spawn_point_heights[x]] = global_pos
	Events.emit_signal("level_spawn_points", spawn_point_dictionary)
	return spawn_point_dictionary
