extends EnemyBase

onready var can_move_single_direction = get_node("%CanMoveSingleDirection")
onready var can_take_damage = get_node("%CanTakeDamage")
onready var can_spawn_collectible = get_node("%CanSpawnCollectible")
onready var can_damage_player_on_touch = get_node("%CanDamagePlayerOnTouch")
onready var can_die_off_screen = get_node("%CanDieOffScreen")


func disable_components():
	can_move_single_direction.queue_free()
	can_take_damage.queue_free()
	can_spawn_collectible.queue_free()
	can_damage_player_on_touch.queue_free()
	can_die_off_screen.queue_free()
