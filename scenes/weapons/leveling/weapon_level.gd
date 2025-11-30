## Defines stat modifiers and upgrades unlocked at a specific weapon level.
extends Resource
class_name WeaponLevel

## The level number (1-based)
@export var level: int = 1

## Stat modifiers (multipliers applied to base stats)
@export_group("Stat Modifiers")
@export var damage_multiplier: float = 1.0
@export var cooldown_multiplier: float = 1.0
@export var duration_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var range_multiplier: float = 1.0

## Flat stat bonuses (added after multipliers)
@export_group("Stat Bonuses")
@export var damage_bonus: int = 0
@export var cooldown_bonus: float = 0.0
@export var duration_bonus: float = 0.0
@export var speed_bonus: float = 0.0
@export var range_bonus: float = 0.0

## Upgrades unlocked at this level
@export_group("Upgrades")
@export var unlocked_upgrades: Array[WeaponUpgrade] = []

## Description shown when reaching this level
@export var level_up_description: String = ""
