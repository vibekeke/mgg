extends Level

func _ready():
	Events.emit_signal("player_invincible", true)
