extends Panel

func add_message_text(text_to_add):
	print("adding text to chat panel", text_to_add)
	$ChatText.append_bbcode(text_to_add)
