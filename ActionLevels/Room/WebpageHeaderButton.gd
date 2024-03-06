tool
extends Panel

onready var button = get_node("%WebpageMenuButton")
onready var margin_container = get_node("%MarginContainer")
export var display_text := ""
onready var rich_text_label = get_node("%RichTextLabel")
onready var center_container = get_node("%CenterContainer")

func _ready():
	print("huh", self.display_text)
	rich_text_label.bbcode_text = self.display_text
	rich_text_label.rect_min_size = rect_width_to_text_length(rich_text_label)
	rich_text_label.rect_size = rect_width_to_text_length(rich_text_label)
	button.rect_min_size = rect_width_to_text_length(rich_text_label)	
	button.rect_size = rect_width_to_text_length(rich_text_label)
	self.rect_size = button.rect_size
	self.rect_min_size = button.rect_size
	center_container.rect_min_size = button.rect_size
	center_container.rect_size = button.rect_size

func bold_and_center_text(text_to_modify: String) -> String:
	return "[center][b]" + text_to_modify + "[/b][/center]"

func rect_width_to_text_length(rich_text_node) -> Vector2:
	return rich_text_node.get_font("bold_font").get_string_size((rich_text_label.bbcode_text))

func _process(delta):
	pass
