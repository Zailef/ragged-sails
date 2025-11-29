## A status effect that slows enemy movement speed.
extends StatusEffect
class_name SlowEffect

## The multiplier applied to movement speed (0.5 = 50% speed)
@export var slow_multiplier: float = 0.5

func _init() -> void:
	id = &"slow"

func get_speed_multiplier() -> float:
	return slow_multiplier
