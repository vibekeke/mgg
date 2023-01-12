extends Control

onready var collected_dog_sprite = preload("CollectedDog.tscn")

func _ready():
	Events.connect("collected_dog", self, "_on_collected_dog")
	_on_level_load()

func _on_collected_dog(dog_breed):
	var container_children = self.get_children()
	var node_to_change
	if dog_breed == "Golden":
		node_to_change = container_children[0]
	if dog_breed == "Labrador":
		node_to_change = container_children[1]
	if dog_breed == "Russel":
		node_to_change = container_children[2]
	if node_to_change != null:
		node_to_change.set_collected_dog(dog_breed)

	
func _on_level_load():
	for i in 3:
		var dog_sprite_node = collected_dog_sprite.instance()
		self.add_child(dog_sprite_node)
