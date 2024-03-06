extends Panel

export (NodePath) var button_label
onready var location_label = get_node(button_label)
export var button_name = ""
var highlight_color = Color(201.0 / 255.0, 255.0 / 255.0, 151.0 / 255.0, 1.0)
var unfocused_theme : StyleBoxTexture = load("res://ActionLevels/Room/WebpageUnfocusedMenu.tres")
var focused_theme : StyleBoxTexture = load("res://ActionLevels/Room/WebpageFocusedMenu.tres")
var mouse_inside = false

func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	self.connect("gui_input", self, "_on_gui_input")
	
func _on_mouse_entered():
	mouse_inside = true
	location_label.modulate = highlight_color
	$MarginContainer/Panel.add_stylebox_override("panel", focused_theme)
	
func _on_mouse_exited():
	mouse_inside = false
	location_label.modulate = Color(1.0,1.0,1.0,1.0)
	$MarginContainer/Panel.add_stylebox_override("panel", unfocused_theme)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and mouse_inside:
		if event.button_index == BUTTON_LEFT:
			print("open correct browser page")
