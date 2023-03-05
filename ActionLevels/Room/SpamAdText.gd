extends RichTextLabel

export (String) var ticker_text = " CONGRATULATIONS YOU ARE THE LUCKY OWNER OF A NEW SPORTS CAR!!!!"

var _text_bar : String = ""
var _ticker_index: int = 40
var _max_length = 43

onready var _timer : Timer = Timer.new()

func _ready():
	_timer.set_name("text_bar_timer")
	_timer.connect("timeout", self, "_on_Timer_timeout")
	self.add_child(_timer)
	_timer.start(0.3)
	_text_bar = ticker_text.substr(0, _ticker_index)

func update_bar():
	_text_bar += ticker_text[_ticker_index]
	_ticker_index += 1
	if _ticker_index >= ticker_text.length():
		_ticker_index = 0
	if _text_bar.length() > _max_length:
		_text_bar = _text_bar.right(1)
	self.set_text(_text_bar)

func _on_Timer_timeout():
	update_bar()
