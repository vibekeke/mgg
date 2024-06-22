extends Node

func wait(seconds: float) -> void:
  print("huh")
  yield(get_tree().create_timer(seconds), "timeout")
