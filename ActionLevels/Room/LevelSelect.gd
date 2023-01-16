extends WindowDialog

onready var last_completed_level : int = 0
onready var level1_image = get_node("%Level1")
onready var level2_image = get_node("%Level2")
onready var level3_image = get_node("%Level3")
onready var level_lore = get_node("%LevelLore")

onready var level1_lore_description = "A forest next to your house. It's full of a bunch of not so friendly animals and a HUGE bird who's kinda cool in an early 2000s emocore kind of way."
onready var level2_lore_description = "They say a \"Banjo Fish\" lives here. But how can a fish play a banjo?"
onready var level3_lore_description = "The big city! Hey...are cities supposed to be this cold!?"

func _ready():
	#for level in Events.COMPLETED_LEVELS:
	for level in [1,2,3]:
		if level == 1:
			level1_image.visible = true
		if level == 2:
			level2_image.visible = true
		if level == 3:
			level3_image.visible = true


func _on_Level1_mouse_entered():
	level_lore.text = level1_lore_description


func _on_Level2_mouse_entered():
	level_lore.text = level2_lore_description


func _on_Level3_mouse_entered():
	level_lore.text = level3_lore_description


func _on_Level1_gui_input(event):
	pass # Replace with function body.


func _on_Level2_gui_input(event):
	pass # Replace with function body.


func _on_Level3_gui_input(event):
	pass # Replace with function body.
