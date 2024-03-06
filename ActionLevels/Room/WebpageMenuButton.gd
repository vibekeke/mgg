tool
extends Panel

onready var rich_text_label = get_node("%RichTextLabel")
onready var center_container = get_node("%CenterContainer")
export var display_text := ""

func _ready():
	# rich_text_label.bbcode_text = bold_and_center_text(self.display_text)
	# print("deez", rich_text_label.bbcode_text)
	# self.rect_size.x = rect_width_to_text_length(rich_text_label).x
	# rich_text_label.rect_min_size = rect_width_to_text_length(rich_text_label)
	# rich_text_label.rect_size = rect_width_to_text_length(rich_text_label)
	# print("rtl rs", rich_text_label.rect_size)
	# center_container.rect_size = self.rect_size
	pass

func bold_and_center_text(text_to_modify: String) -> String:
	return "[center][b]" + text_to_modify + "[/b][/center]"

func rect_width_to_text_length(rich_text_node) -> Vector2:
	return rich_text_node.get_font("bold_font").get_string_size((self.display_text))
