extends Node2D


func _ready():
	Events.connect("bedroom_lights_on", self, "_on_bedroom_lights_on")
	
func _on_bedroom_lights_on(status):
	self.visible = status
