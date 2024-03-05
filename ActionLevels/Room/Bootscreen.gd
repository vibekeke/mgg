extends Sprite

onready var label_container = get_node("%VBoxContainer")
onready var logo_appear_tween = get_node("%LogoAppearTween")
onready var text_appear_timer = get_node("%TextAppearTimer")
onready var computer_boot_logo = get_node("%ComputerBootLogo")

func _ready():
	var all_labels = label_container.get_children()
	var num_labels = len(all_labels)
	var midpoint = num_labels / 2
	for x in range(0, num_labels):
		all_labels[x].visible = false
	computer_boot_logo.modulate.a = 0
	for x in range(0, num_labels):
		if all_labels[x].name != 'SpinningCursor':
			all_labels[x].visible = false
	start_bootscreen()

func start_bootscreen():
	var all_labels = label_container.get_children()
	var quarter_point = round(len(all_labels) * 0.25)
	print("quarter point", quarter_point)
	for x in range(0, len(all_labels)):
		if x == quarter_point:
			logo_appear_tween.interpolate_property(computer_boot_logo, "modulate", computer_boot_logo.modulate, Color(1,1,1,1), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			logo_appear_tween.start()
		all_labels[x].visible = true
		yield(get_tree().create_timer(0.5), "timeout")
