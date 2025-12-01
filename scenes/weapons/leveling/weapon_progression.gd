## Contains the complete leveling progression for a weapon.
## Assign this to a weapon to define its upgrade path.
extends Resource
class_name WeaponProgression

## Display name of the weapon
@export var weapon_name: String = ""

## Maximum level before overflow scaling kicks in
@export var max_level: int = 5

## All level definitions (index 0 = level 1, etc.)
@export var levels: Array[WeaponLevel] = []

## Overflow scaling (applied per level beyond max_level)
@export_group("Overflow Scaling")
## Whether to allow levels beyond max_level with diminishing returns
@export var allow_overflow: bool = true
## Damage multiplier per overflow level (e.g., 1.02 = +2% per level)
@export var overflow_damage_multiplier: float = 1.02
## Cooldown multiplier per overflow level (e.g., 0.99 = -1% per level)
@export var overflow_cooldown_multiplier: float = 0.99
## Duration multiplier per overflow level
@export var overflow_duration_multiplier: float = 1.01
## Speed multiplier per overflow level
@export var overflow_speed_multiplier: float = 1.01
## Optional curve for overflow scaling (x = overflow levels, y = multiplier applied to overflow bonuses)
## If null, a default diminishing returns curve is used
@export var overflow_curve: Curve

## Cached default curve for diminishing returns
static var _default_curve: Curve


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
	
	# Apply defined levels
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
	
	# Apply overflow scaling for levels beyond max_level
	if allow_overflow and current_level > max_level:
		var overflow_levels = current_level - max_level
		
		# Apply overflow multipliers (with curve scaling)
		for i in range(overflow_levels):
			var level_curve = _get_overflow_curve_multiplier(i + 1)
			modifiers["damage_multiplier"] *= lerpf(1.0, overflow_damage_multiplier, level_curve)
			modifiers["cooldown_multiplier"] *= lerpf(1.0, overflow_cooldown_multiplier, level_curve)
			modifiers["duration_multiplier"] *= lerpf(1.0, overflow_duration_multiplier, level_curve)
			modifiers["speed_multiplier"] *= lerpf(1.0, overflow_speed_multiplier, level_curve)
	
	return modifiers


## Gets the curve multiplier for a given number of overflow levels
## Uses custom curve if provided, otherwise uses default diminishing returns
func _get_overflow_curve_multiplier(overflow_levels: int) -> float:
	var curve = overflow_curve if overflow_curve else _get_default_curve()
	# Normalize overflow levels to 0-1 range (assumes curve covers ~50 overflow levels)
	var normalized = clampf(overflow_levels / 50.0, 0.0, 1.0)
	return curve.sample(normalized)


## Creates and caches a default diminishing returns curve
static func _get_default_curve() -> Curve:
	if _default_curve:
		return _default_curve
	
	_default_curve = Curve.new()
	# Diminishing returns: starts at full effect, tapers off
	# (0.0, 1.0) -> (0.2, 0.7) -> (0.5, 0.4) -> (0.8, 0.2) -> (1.0, 0.1)
	_default_curve.add_point(Vector2(0.0, 1.0), 0, -1.5)
	_default_curve.add_point(Vector2(0.3, 0.5), -1.0, -0.8)
	_default_curve.add_point(Vector2(0.6, 0.25), -0.5, -0.3)
	_default_curve.add_point(Vector2(1.0, 0.1), -0.2, 0)
	_default_curve.bake()
	
	return _default_curve
