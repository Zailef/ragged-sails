## Fires a third cannonball shortly after the second.
extends WeaponUpgrade
class_name TripleShotUpgrade

## Delay before firing the third cannonball (in seconds)
@export var shot_delay: float = 0.30


func _init() -> void:
	id = &"triple_shot"
	display_name = "Triple Shot"
	description = "Fire a third cannonball."


func on_fire(weapon: BaseWeapon) -> void:
	var cannon = weapon as Cannonball
	if cannon:
		cannon.queue_cannonball(shot_delay)
