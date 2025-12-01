## Quad Anchors - Spawns a fourth anchor evenly spaced.
extends WeaponUpgrade
class_name QuadAnchorsUpgrade


func on_fire(weapon: BaseWeapon) -> void:
	var anchor = weapon as Anchor
	if anchor and anchor.get_anchor_count() == 3:
		anchor.add_anchor_and_redistribute()
