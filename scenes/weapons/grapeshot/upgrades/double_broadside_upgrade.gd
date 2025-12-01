## Fires a second volley on each side for a devastating 4-volley alternating barrage.
## When combined with Broadside, creates pattern: Right, Left, Right, Left
extends WeaponUpgrade
class_name DoubleBroadsideUpgrade

## Delay between each volley in the alternating sequence
@export var volley_interval: float = 0.1


func _init() -> void:
	id = &"double_broadside"
	display_name = "Double Broadside"
	description = "Fire 2 volleys per side in an alternating barrage."


func on_fire(weapon: BaseWeapon) -> void:
	var grapeshot := weapon as Grapeshot
	if not grapeshot:
		return
	
	# Base fire: 0.0s Right (last_direction)
	# We add: 0.1s Left, 0.2s Right, 0.3s Left
	# Result: R, L, R, L (perfect alternating)
	var right := grapeshot.last_direction
	var left := -right
	
	grapeshot.queue_volley(left, volley_interval) # 0.1s Left
	grapeshot.queue_volley(right, volley_interval * 2) # 0.2s Right
	grapeshot.queue_volley(left, volley_interval * 3) # 0.3s Left
