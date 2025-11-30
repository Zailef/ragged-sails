## Contains the complete leveling progression for a weapon.
## Assign this to a weapon to define its upgrade path.
extends Resource
class_name WeaponProgression

## Display name of the weapon
@export var weapon_name: String = ""

## Maximum level this weapon can reach
@export var max_level: int = 5

## All level definitions (index 0 = level 1, etc.)
@export var levels: Array[WeaponLevel] = []


## Gets the WeaponLevel for a specific level number (1-based)
func get_level(level_num: int) -> WeaponLevel:
	var index = level_num - 1
	if index >= 0 and index < levels.size():
		return levels[index]
	return null


## Gets all upgrades unlocked up to and including the given level
func get_unlocked_upgrades(current_level: int) -> Array[WeaponUpgrade]:
	var upgrades: Array[WeaponUpgrade] = []
	for i in range(min(current_level, levels.size())):
		for upgrade in levels[i].unlocked_upgrades:
			if upgrade and not upgrades.has(upgrade):
				upgrades.append(upgrade)
	return upgrades


## Calculates cumulative stat modifiers up to the given level
func get_cumulative_modifiers(current_level: int) -> Dictionary:
	var modifiers = {
		"damage_multiplier": 1.0,
		"cooldown_multiplier": 1.0,
		"duration_multiplier": 1.0,
		"speed_multiplier": 1.0,
		"range_multiplier": 1.0,
		"damage_bonus": 0,
		"cooldown_bonus": 0.0,
		"duration_bonus": 0.0,
		"speed_bonus": 0.0,
		"range_bonus": 0.0,
	}
	
	for i in range(min(current_level, levels.size())):
		var level = levels[i]
		# Multipliers stack multiplicatively
		modifiers["damage_multiplier"] *= level.damage_multiplier
		modifiers["cooldown_multiplier"] *= level.cooldown_multiplier
		modifiers["duration_multiplier"] *= level.duration_multiplier
		modifiers["speed_multiplier"] *= level.speed_multiplier
		modifiers["range_multiplier"] *= level.range_multiplier
		# Bonuses stack additively
		modifiers["damage_bonus"] += level.damage_bonus
		modifiers["cooldown_bonus"] += level.cooldown_bonus
		modifiers["duration_bonus"] += level.duration_bonus
		modifiers["speed_bonus"] += level.speed_bonus
		modifiers["range_bonus"] += level.range_bonus
	
	return modifiers
