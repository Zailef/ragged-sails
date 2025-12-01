## Fires a fourth cannonball shortly after the third.
extends WeaponUpgrade
class_name QuadShotUpgrade

## Delay before firing the fourth cannonball (in seconds)
@export var shot_delay: float = 0.45


func _init() -> void:
	id = &"quad_shot"
	display_name = "Quad Shot"
	description = "Fire a fourth cannonball."


func on_fire(weapon: BaseWeapon) -> void:
	var cannon = weapon as Cannonball
	if cannon:
		cannon.queue_cannonball(shot_delay)
