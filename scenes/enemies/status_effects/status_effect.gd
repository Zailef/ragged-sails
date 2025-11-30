## Base class for all status effects that can be applied to enemies.
## Extend this to create specific effects like slow, burn, freeze, etc.
extends Resource
class_name StatusEffect

## Unique identifier for this effect type (used for stacking/overwriting)
@export var id: StringName = &""

## Duration in seconds. 0 = permanent until manually removed
@export var duration: float = 0.0

## Whether multiple instances of this effect can stack
@export var can_stack: bool = false

## Maximum number of stacks (only used if can_stack is true)
@export var max_stacks: int = 1


## Returns the speed multiplier this effect applies. Override in subclasses.
func get_speed_multiplier() -> float:
	return 1.0


## Returns the damage taken multiplier this effect applies. Override in subclasses.
func get_damage_taken_multiplier() -> float:
	return 1.0


## Returns the damage dealt multiplier this effect applies. Override in subclasses.
func get_damage_dealt_multiplier() -> float:
	return 1.0


## Called when the effect is first applied to an enemy.
func on_apply(_enemy: Enemy) -> void:
	pass


## Called when the effect is removed from an enemy.
func on_remove(_enemy: Enemy) -> void:
	pass


## Called every frame while the effect is active.
func on_tick(_enemy: Enemy, _delta: float) -> void:
	pass
