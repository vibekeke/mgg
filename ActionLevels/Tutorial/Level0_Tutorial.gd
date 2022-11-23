extends Node2D

onready var transition_timer = Timer.new()
onready var transitioning = false

func _ready():
	transition_timer.set_name("transition_timer")
	transition_timer.connect("timeout", self, "_on_transition_timer")
	transition_timer.set_wait_time(1.5)
	self.add_child(transition_timer)

func _on_transition_timer():
	Events.transition_to_new_scene("Level1")

func _process(delta):
	pass
#	var present_bee = get_node_or_null("Misbeehave")
#	if present_bee == null:
#		if !transitioning:
#			transition_timer.start()
#			transitioning = true
