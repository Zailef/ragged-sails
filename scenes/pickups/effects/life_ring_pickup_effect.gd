extends PickupEffect
class_name LifeRingPickupEffect

@export var health_gain: int = 25

func apply_effect(_pickup: Pickup, player: Player) -> void:
	player.current_health += health_gain
