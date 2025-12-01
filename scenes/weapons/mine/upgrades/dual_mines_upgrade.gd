## Dual Mines - Drops a second mine behind the player.
extends WeaponUpgrade
class_name DualMinesUpgrade


func on_fire(weapon: BaseWeapon) -> void:
	var mine = weapon as Mine
	if mine:
		mine.spawn_mine_behind_player()
