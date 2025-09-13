class_name LevelStats
extends Resource

var level_name : String
var level_number : int
var level_started : bool
var last_run_completed : bool
var killed_enemies : int = 0
var current_achieved_score : int = 0

# if the enemy is an 'air' type of a 'ground' type
var killed_enemy_environment : Dictionary = { "Air": 0, "Ground": 0}
var player_performed_actions : Dictionary = {
	"jump": 0,
	"float": 0,
	"shoot": 0,
	"slide": 0,
	"hits_taken": 0
}

func increment_player_jump():
	player_performed_actions['jump'] += 1
	
func increment_player_float():
	player_performed_actions['float'] += 1
	
func increment_killed_enemies(enemy_environment: String):
	killed_enemies += 1
	killed_enemy_environment[enemy_environment] += 1
	
func reset_all():
	killed_enemies = 0
	killed_enemy_environment = { "Air": 0, "Ground": 0 }
	player_performed_actions = { "jump": 0, "float": 0, "shoot": 0, "slide": 0 }
