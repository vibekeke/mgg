extends Node

export (NodePath) var light_affected_item
export (bool) var affected_by_light = true

func _ready():
	Events.connect("bedroom_lights_on", self, "_on_bedroom_lights_on")

func shader_state(state):
	if affected_by_light:
		var material = get_node(light_affected_item).material as ShaderMaterial
		if material:
			material.set_shader_param("apply_effect", state)
		else:
			print("No material found for item: ", self.name)

func _on_bedroom_lights_on(state):
	shader_state(state)
