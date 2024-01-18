extends BaseLevelEvent

onready var bee = get_node("%NewMisbeehave")

func _ready():
	bee.enable_movement(false)
	bee.disable_damage(true)
	bee.disable_touch_damage(true)

func _on_Level1_Event1_visibility_changed():
	if self.visible:
		if is_instance_valid(bee):
			bee.enable_movement(true)
