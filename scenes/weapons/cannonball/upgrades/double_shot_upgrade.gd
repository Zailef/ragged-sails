## Fires a second cannonball shortly after the first.
extends WeaponUpgrade
class_name DoubleShotUpgrade

## Delay before firing the second cannonball (in seconds)
@export var shot_delay: float = 0.15


func _init() -> void:
	id = &"double_shot"
	display_name = "Double Shot"
	description = "Fire a second cannonball shortly after the first."


func on_fire(weapon: BaseWeapon) -> void:
	var cannon = weapon as Cannonball
	if cannon:
		cannon.queue_cannonball(shot_delay)
