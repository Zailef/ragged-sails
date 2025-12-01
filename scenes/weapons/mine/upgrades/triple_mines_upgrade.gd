## Triple Mines - Drops a third mine in front of the player.
extends WeaponUpgrade
class_name TripleMinesUpgrade


func on_fire(weapon: BaseWeapon) -> void:
	var mine = weapon as Mine
	if mine:
		mine.spawn_mine_ahead_of_player()
