## Manages a weapon's current level, stats, and active upgrades.
## Add as a child node to any weapon that supports leveling.
extends Node
class_name WeaponLevelManager

signal level_changed(new_level: int)
signal upgrade_unlocked(upgrade: WeaponUpgrade)

## The progression data for this weapon
@export var progression: WeaponProgression

## Current level (1-based)
var current_level: int = 1:
	set(value):
		var old_level = current_level
		current_level = clamp(value, 1, progression.max_level if progression else 1)
		if current_level != old_level:
			_on_level_changed(old_level)

## Currently active upgrades
var active_upgrades: Array[WeaponUpgrade] = []

## Cached stat modifiers
var _cached_modifiers: Dictionary = {}

## Reference to the weapon this manager belongs to
var weapon: BaseWeapon


func _ready() -> void:
	weapon = get_parent() as BaseWeapon
	_refresh_level_data()


## Levels up the weapon if possible, returns true if successful
func level_up() -> bool:
	if not progression:
		return false
	if current_level >= progression.max_level:
		return false
	
	current_level += 1
	return true


## Checks if a specific upgrade is active
func has_upgrade(upgrade_id: StringName) -> bool:
	for upgrade in active_upgrades:
		if upgrade.id == upgrade_id:
			return true
	return false


## Gets an active upgrade by ID, or null if not found
func get_upgrade(upgrade_id: StringName) -> WeaponUpgrade:
	for upgrade in active_upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null


## Gets the effective damage after applying level modifiers
func get_effective_damage(base_damage: int) -> int:
	var multiplier = _cached_modifiers.get("damage_multiplier", 1.0)
	var bonus = _cached_modifiers.get("damage_bonus", 0)
	return int(base_damage * multiplier) + bonus


## Gets the effective cooldown after applying level modifiers
func get_effective_cooldown(base_cooldown: float) -> float:
	var multiplier = _cached_modifiers.get("cooldown_multiplier", 1.0)
	var bonus = _cached_modifiers.get("cooldown_bonus", 0.0)
	return max(0.1, base_cooldown * multiplier + bonus)


## Gets the effective duration after applying level modifiers
func get_effective_duration(base_duration: float) -> float:
	var multiplier = _cached_modifiers.get("duration_multiplier", 1.0)
	var bonus = _cached_modifiers.get("duration_bonus", 0.0)
	return max(0.0, base_duration * multiplier + bonus)


## Gets the effective speed after applying level modifiers
func get_effective_speed(base_speed: float) -> float:
	var multiplier = _cached_modifiers.get("speed_multiplier", 1.0)
	var bonus = _cached_modifiers.get("speed_bonus", 0.0)
	return base_speed * multiplier + bonus


## Gets the effective range after applying level modifiers
func get_effective_range(base_range: float) -> float:
	if base_range < 0: # Unlimited range
		return base_range
	var multiplier = _cached_modifiers.get("range_multiplier", 1.0)
	var bonus = _cached_modifiers.get("range_bonus", 0.0)
	return base_range * multiplier + bonus


## Called when level changes
func _on_level_changed(old_level: int) -> void:
	_refresh_level_data()
	
	# Notify about newly unlocked upgrades
	if progression:
		var old_upgrades = progression.get_unlocked_upgrades(old_level)
		for upgrade in active_upgrades:
			if not old_upgrades.has(upgrade):
				upgrade.on_unlock(weapon)
				upgrade_unlocked.emit(upgrade)
	
	level_changed.emit(current_level)


## Refreshes cached modifiers and active upgrades based on current level
func _refresh_level_data() -> void:
	if not progression:
		_cached_modifiers = {}
		active_upgrades = []
		return
	
	_cached_modifiers = progression.get_cumulative_modifiers(current_level)
	active_upgrades = progression.get_unlocked_upgrades(current_level)


## Calls on_physics_process for all active upgrades
func process_upgrades(delta: float) -> void:
	for upgrade in active_upgrades:
		upgrade.on_physics_process(weapon, delta)


## Calls on_fire for all active upgrades
func notify_fire() -> void:
	for upgrade in active_upgrades:
		upgrade.on_fire(weapon)


## Calls on_hit for all active upgrades
func notify_hit(enemy: Enemy) -> void:
	for upgrade in active_upgrades:
		upgrade.on_hit(weapon, enemy)


## Calls on_reset for all active upgrades
func notify_reset() -> void:
	for upgrade in active_upgrades:
		upgrade.on_reset(weapon)
