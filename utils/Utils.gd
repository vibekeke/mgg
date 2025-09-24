extends Node

func wait(seconds: float) -> void:
  print("huh")
  await get_tree().create_timer(seconds).timeout
