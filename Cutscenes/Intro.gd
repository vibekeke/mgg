extends Node2D

var tv_sound_finished = false
export var intro_dialog : Resource

func _ready():
	MggDialogue.connect("mgg_dialogue_box_finished", self, "_on_dialogue_box_finished")
	$TVTurnOn.play()
	$CanvasLayer/VHS.set_modulate(Color(1,1,1,0))
	$AyyLmao.set_modulate(Color(1,1,1,0))
	$AyyLmao2.set_modulate(Color(1,1,1,0))

func _on_dialogue_box_finished(node_id):
	if self.get_instance_id() == node_id:
		yield(get_tree().create_timer(2.0), "timeout")
		Events.emit_signal("transition_to_scene", "DemoEndCredits", false)

func display_dialogue():
	MggDialogue.create_dialogue_balloon(
		"intro",
		intro_dialog,
		self.get_instance_id(),
		DataClasses.Placement.LOWER,
		DataClasses.CharacterPortrait.None,
		Color(0.25, 0.18, 0.7, 0.5),
		Color(0.0, 0.0, 0.0, 0.25)
	)

func _process(delta):
	if tv_sound_finished:
		$CanvasLayer/VHS.set_modulate(lerp($CanvasLayer/VHS.get_modulate(), Color(1,1,1,1), 0.05))
		$AyyLmao.set_modulate(lerp($AyyLmao.get_modulate(), Color(1,1,1,0.1), 0.05))
		$AyyLmao2.set_modulate(lerp($AyyLmao2.get_modulate(), Color(1,1,1,0.1), 0.05))

func _on_TVTurnOn_finished():
	tv_sound_finished = true
	display_dialogue()
