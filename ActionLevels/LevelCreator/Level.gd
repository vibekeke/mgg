class_name Level
extends Node2D

@export var level_name : String
@export var spawn_path : NodePath
@onready var spawn_points = get_node(spawn_path)

@export var enemy_pooler_path : NodePath
@onready var enemy_pool = get_node(enemy_pooler_path)

@export var mute_audio : bool = false

@export var screen_filter_path : NodePath
@onready var screen_filter = get_node(screen_filter_path)

@export var level_start_display_path : NodePath
@onready var level_start_display = get_node(level_start_display_path)

@export var level_track_path : String

signal level_start


func _ready():
	ScoreManager.reset_level_score()
	Events.set_vhs_shader(Events.vhs_filter_state_unpaused, screen_filter)
	level_start_display.connect("confirm_level_start", Callable(self, "_on_confirm_level_start"))
	Events.emit_signal("background_moving_enabled", false)
	Events.emit_signal("player_standing", true)
	enemy_pool.stop_spawner()

	# AudioManager.play_music("special_beach_level")

func _on_confirm_level_start():
	AudioManager.playSFX("ui_confirm")
	Events.emit_signal("background_moving_enabled", true)
	Events.emit_signal("player_standing", false)
	Events.emit_signal("fall_down_ui")
	self.emit_signal("level_start")
	enemy_pool.start_spawner()

