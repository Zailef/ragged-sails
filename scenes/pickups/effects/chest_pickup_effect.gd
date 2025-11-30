extends PickupEffect
class_name ChestPickupEffect

## When collected, emits a signal to trigger the weapon upgrade selection UI.

func apply_effect(_pickup: Pickup, _player: Player) -> void:
	SignalManager.chest_collected.emit()
