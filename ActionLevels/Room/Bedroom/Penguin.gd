extends Sprite

var dialogue_titles = ['bedroom_penguin', 'bedroom_penguin_2', 'bedroom_penguin_3']
onready var can_create_dialogue = get_node("%CanCreateDialogue")
var initial_dialogue_title_index = 0

func _ready():
	can_create_dialogue.connect("created_dialogue_over", self, "_on_created_dialogue_over")
	can_create_dialogue.title = dialogue_titles[initial_dialogue_title_index]
	
func _on_created_dialogue_over():
	print("bumping index")
	initial_dialogue_title_index += 1
	if initial_dialogue_title_index > dialogue_titles.size() - 1:
		initial_dialogue_title_index = 0
	can_create_dialogue.title = dialogue_titles[initial_dialogue_title_index]
