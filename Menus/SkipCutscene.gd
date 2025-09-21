extends CanvasLayer

signal skip_cutscene

onready var is_cutscene_skippable : bool = SaveFileManager.get_beaten_first_level_before()
onready var skip_hint = get_node("%SkipLabel")
export(float) var hide_hint_after := 2.5
export(float) var hold_seconds := 1.5
export(float) var shake_strength := 7.0
export(float) var shake_interval := 0.1    # seconds between new random targets
export(float) var shake_lerp_speed := 10.0 # how quickly to approach target

var show_hint = false
var hint_target_alpha = 0.0
var held_time = 0.0
var hide_timer = 0.0

var skipped = false

var base_pos : Vector2
var shake_time := 0.0
var current_offset := Vector2.ZERO
var target_offset := Vector2.ZERO


func _ready():
	skip_hint.set_modulate(Color(1,1,1,0))
	show_hint = is_cutscene_skippable
	hide_timer = hide_hint_after
	base_pos = skip_hint.rect_position

func _process(delta):
	if skipped:
		return
	#autohide skip_label countdown
	if show_hint and not Input.is_action_pressed("skip"):
		hide_timer -= delta
		if hide_timer <= 0.0:
			show_hint = false
	
	#hold skip accumulation
	if is_cutscene_skippable and Input.is_action_pressed("skip"):
		held_time += delta
		
		if held_time >= hold_seconds:
			skipped = true #Stops process from running after skip
			_on_skip_confirmed()
		
		#Make the label shake to show player input
		_apply_shake(delta)
	else:
		held_time = 0.0
		shake_time = 0.0
		current_offset = Vector2.ZERO
		target_offset = Vector2.ZERO
		skip_hint.rect_position = base_pos
	
	#Modulate with lerp
	if show_hint:
		hint_target_alpha = 1.0
	else: 
		hint_target_alpha = 0.0
	
	skip_hint.set_modulate(lerp(skip_hint.get_modulate(), Color(1, 1, 1, hint_target_alpha), 0.05))

func _input(event):
	if not is_cutscene_skippable:
		return
	#show skip_hint if any key is pressed aside from dialogue advancement.
	if event is InputEventKey and event.pressed:
		if not event.is_action("ui_accept"):
			show_hint = true
			hide_timer = hide_hint_after
	elif event is InputEventMouseButton and event.pressed:
		if not event.is_action("click"):
			show_hint = true
			hide_timer = hide_hint_after

func _apply_shake(delta):
	shake_time += delta
	if shake_time >= shake_interval:
		# pick a new random target
		target_offset = Vector2(
			rand_range(-shake_strength, shake_strength),
			rand_range(-shake_strength, shake_strength) * 0.5
		)
		shake_time = 0.0
	# move smoothly toward target
	current_offset = current_offset.linear_interpolate(target_offset, shake_lerp_speed * delta)
	skip_hint.rect_position = base_pos + current_offset
	
func _on_skip_confirmed():
	skip_hint.rect_position = base_pos
	skip_hint.visible = false
	emit_signal("skip_cutscene")
