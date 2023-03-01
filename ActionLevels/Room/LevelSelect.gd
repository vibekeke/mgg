extends WindowDialog

onready var last_completed_level : int = 0
onready var level1_image = get_node("%Level1")
onready var level2_image = get_node("%Level2")
onready var level3_image = get_node("%Level3")
onready var level_lore = get_node("%LevelLore")

onready var level1_lore_description : String = "A forest next to your house. It's full of a bunch of not so friendly animals."
onready var level2_lore_description : String = "They say a \"Banjo Fish\" lives here. But how can a fish play a banjo?"
onready var level3_lore_description : String = "The big city! Hey...are cities supposed to be this cold in July!?"

onready var window_dialog_title : String = "WELCOME TO THE WEB!!!"
onready var alternate_dialog_title : String = "ワルドワイドウエボ！！！"
onready var title_to_use : String = ""

var global_scroller : int = 1
onready var _timer : Timer = Timer.new()
onready var _flicker_timer : Timer = Timer.new()

func _ready():
	_timer.connect("timeout", self, "_on_window_title_update")
	_timer.set_wait_time(0.65)
	_timer.set_one_shot(false)
	self.window_title = ""
	title_to_use = window_dialog_title
	self.add_child(_timer)
	
	_timer.start()
	_flicker_timer.connect("timeout", self, "_on_flicker_title_update")
	_flicker_timer.set_wait_time(1)
	_flicker_timer.set_one_shot(false)
	self.add_child(_flicker_timer)
	_flicker_timer.start()
	
	# TODO: Remember to revert this back when finished testing
	#for level in Events.COMPLETED_LEVELS:
	for level in [1,2,3]:
		if level == 1:
			level1_image.visible = true
		if level == 2:
			level2_image.visible = true
		if level == 3:
			level3_image.visible = true

func _on_flicker_title_update():
	pass

func _on_window_title_update():
	self.window_title = title_to_use.substr(0, global_scroller)
	global_scroller += 1
	if global_scroller > len(title_to_use):
		global_scroller = 0
		if title_to_use == window_dialog_title:
			title_to_use = alternate_dialog_title
		else:
			title_to_use = window_dialog_title
		
func _on_Level1_mouse_entered():
	level_lore.text = level1_lore_description
	level1_image.material.set_shader_param('width', 10)

func _on_Level2_mouse_entered():
	level_lore.text = level2_lore_description
	level2_image.material.set_shader_param('width', 10)

func _on_Level3_mouse_entered():
	level_lore.text = level3_lore_description
	level3_image.material.set_shader_param('width', 10)

func _on_Level1_mouse_exited():
	level1_image.material.set_shader_param('width', 0)

func _on_Level2_mouse_exited():
	level2_image.material.set_shader_param('width', 0)


func _on_Level3_mouse_exited():
	level3_image.material.set_shader_param('width', 0)


func _on_Level1_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			print("transition to level 1")
			Events.emit_signal("transition_to_scene", "Level1")



func _on_Level2_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			Events.emit_signal("transition_to_scene", "Level2")


func _on_Level3_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			Events.emit_signal("transition_to_scene", "Level3")


