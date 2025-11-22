extends PickupEffect
class_name ExpPickupEffect

@export var exp_value: int = 1

func apply_effect(pickup: Pickup, player: Player) -> void:
	player.add_experience(exp_value)
