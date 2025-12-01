## Tri Anchors - Spawns a third anchor evenly spaced.
extends WeaponUpgrade
class_name TriAnchorsUpgrade


func on_fire(weapon: BaseWeapon) -> void:
	var anchor = weapon as Anchor
	if anchor and anchor.get_anchor_count() == 2:
		anchor.add_anchor_and_redistribute()
