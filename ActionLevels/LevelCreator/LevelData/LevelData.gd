tool
extends Resource
class_name LevelData

export var level_name : String
export var num_phases : int 
export (Array, int) var phase_times
export (Array, PackedScene) var enemies
export (Array, PackedScene) var obstacles
