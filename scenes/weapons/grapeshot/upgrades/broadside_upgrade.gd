## Fires a second grapeshot volley to the opposite side after a short delay.
extends WeaponUpgrade
class_name BroadsideUpgrade

## Delay before firing the second volley (in seconds)
@export var volley_delay: float = 0.2


func _init() -> void:
	id = &"broadside"
	display_name = "Broadside"
	description = "Fire a second volley to the opposite side."


func on_fire(weapon: BaseWeapon) -> void:
	var grapeshot := weapon as Grapeshot
	if not grapeshot:
		return

	# Double Broadside supersedes this upgrade with its own 4-volley pattern
	if grapeshot.level_manager and grapeshot.level_manager.has_upgrade(&"double_broadside"):
		return

	# Queue a second volley in the opposite direction
	grapeshot.queue_volley(-grapeshot.last_direction, volley_delay)
