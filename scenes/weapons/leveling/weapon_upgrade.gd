## Base class for weapon upgrades that modify behavior.
## Extend this to create specific upgrades like electrified rope, piercing shots, etc.
extends Resource
class_name WeaponUpgrade

## Unique identifier for this upgrade
@export var id: StringName = &""

## Display name shown to player
@export var display_name: String = ""

## Description of what this upgrade does
@export var description: String = ""

## Icon for UI display
@export var icon: Texture2D


## Called when the upgrade is first unlocked on a weapon
func on_unlock(_weapon: BaseWeapon) -> void:
	pass


## Called every physics frame while the weapon is active (optional)
func on_physics_process(_weapon: BaseWeapon, _delta: float) -> void:
	pass


## Called when the weapon fires (optional)
func on_fire(_weapon: BaseWeapon) -> void:
	pass


## Called when the weapon hits an enemy (optional)
func on_hit(_weapon: BaseWeapon, _enemy: Enemy) -> void:
	pass


## Called when the weapon's active phase ends (optional)
func on_reset(_weapon: BaseWeapon) -> void:
	pass
