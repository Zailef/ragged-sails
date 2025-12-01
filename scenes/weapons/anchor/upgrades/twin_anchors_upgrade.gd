## Twin Anchors - Spawns a second anchor evenly spaced.
extends WeaponUpgrade
class_name TwinAnchorsUpgrade


func on_fire(weapon: BaseWeapon) -> void:
	var anchor = weapon as Anchor
	if anchor and anchor.get_anchor_count() == 1:
		anchor.add_anchor_and_redistribute()
