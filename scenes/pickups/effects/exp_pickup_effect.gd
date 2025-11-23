extends PickupEffect
class_name ExpPickupEffect

@export var exp_value: int = 1

func apply_effect(_pickup: Pickup, player: Player) -> void:
	SignalManager.exp_gained.emit(exp_value)
	player.add_experience(exp_value)
