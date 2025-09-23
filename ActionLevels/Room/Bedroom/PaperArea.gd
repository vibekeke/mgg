extends Sprite

onready var sparkles = get_node("%Sparkles")
# onready var tween = get_node("%Tween")  # Commented out for Godot 4 compatibility
var sparkle_tween : SceneTreeTween  # New Godot 4 tween

export var dialogue_resource: Resource
export var dialogue_title := "bedroom_piano"

signal open_challenge_menu

var player_in_area : bool = false
var dialogue_over : bool = false

func _ready():
	sparkles.modulate.a = 0.0
	
func _on_Area2D_body_entered(body):
	if body.name == "OverworldPlayer":
		player_in_area = true
		

func _on_Area2D_body_exited(body):
	if body.name == "OverworldPlayer":
		player_in_area = false

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player_in_area:
		Events.emit_signal("overworld_player_controlled", true)
		emit_signal("open_challenge_menu")

func _tween_sparkles(target_alpha: float):
	# Old tween code commented out for Godot 4 compatibility:
	# tween.stop_all()
	# tween.interpolate_property(
	# 	sparkles, "modulate:a", sparkles.modulate.a, target_alpha, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	# tween.start()

	# New Godot 4 tween:
	if sparkle_tween != null and sparkle_tween.is_valid():
		sparkle_tween.kill()
	sparkle_tween = get_tree().create_tween()
	sparkle_tween.tween_property(sparkles, "modulate:a", target_alpha, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_SparkleZone_body_entered(body):
	if body.name == "OverworldPlayer":
		_tween_sparkles(1.0)


func _on_SparkleZone_body_exited(body):
	if body.name == "OverworldPlayer":
		_tween_sparkles(0.0)
