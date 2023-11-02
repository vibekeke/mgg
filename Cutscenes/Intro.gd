extends Node2D

onready var intro_cutscene_dialogue = Dialogic.start('Cutscenes/IntroCutscene')
var tv_sound_finished = false

func _ready():
	$TVTurnOn.play()
	$CanvasLayer/VHS.set_modulate(Color(1,1,1,0))
	$AyyLmao.set_modulate(Color(1,1,1,0))
	$AyyLmao2.set_modulate(Color(1,1,1,0))
	
	#intro_cutscene_dialogue.connect("")

func _process(delta):
	if tv_sound_finished:
		$CanvasLayer/VHS.set_modulate(lerp($CanvasLayer/VHS.get_modulate(), Color(1,1,1,1), 0.05))
		$AyyLmao.set_modulate(lerp($AyyLmao.get_modulate(), Color(1,1,1,0.1), 0.05))
		$AyyLmao2.set_modulate(lerp($AyyLmao2.get_modulate(), Color(1,1,1,0.1), 0.05))

func _on_TVTurnOn_finished():
	tv_sound_finished = true
	self.add_child(intro_cutscene_dialogue)
