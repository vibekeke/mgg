extends Control

onready var collected_dog = $CollectedDogSprite

func _ready():
	collected_dog.set_animation("empty")

func set_collected_dog(dog_breed):
	collected_dog.set_animation(dog_breed.to_lower())
