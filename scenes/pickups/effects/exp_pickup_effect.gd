extends PickupEffect
class_name ExpPickupEffect

@export var exp_value: int = 1

func apply_effect(_pickup: Pickup, _player: Player) -> void:
	SignalManager.exp_gained.emit(exp_value)
