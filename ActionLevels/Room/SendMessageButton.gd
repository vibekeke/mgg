extends Button

onready var chat_text_sender = get_node_or_null("%ChatTextSender")
onready var chat_box = get_node_or_null("%ChatBox")

func _ready():
	pass


func _on_SendMessageButton_button_up():
	var text_to_send : String = chat_text_sender.text
	print("text to send is", text_to_send)
	chat_box
