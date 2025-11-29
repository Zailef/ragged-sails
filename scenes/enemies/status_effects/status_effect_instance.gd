## Wrapper that tracks an active status effect and its remaining duration.
## This allows the same StatusEffect resource to be used on multiple enemies
## with independent duration tracking.
extends RefCounted
class_name StatusEffectInstance

var effect: StatusEffect
var remaining_duration: float
var stack_count: int = 1
var source: Node = null # Optional reference to what applied this effect


func _init(p_effect: StatusEffect, p_source: Node = null) -> void:
	effect = p_effect
	remaining_duration = p_effect.duration
	source = p_source


## Returns true if this effect has expired (only for timed effects)
func is_expired() -> bool:
	# Duration of 0 means permanent
	if effect.duration <= 0:
		return false
	return remaining_duration <= 0


## Updates the remaining duration. Returns true if still active.
func tick(delta: float) -> bool:
	if effect.duration > 0:
		remaining_duration -= delta
	return not is_expired()


## Refreshes the duration to the original value
func refresh() -> void:
	remaining_duration = effect.duration


## Adds a stack if allowed, returns true if stack was added
func add_stack() -> bool:
	if effect.can_stack and stack_count < effect.max_stacks:
		stack_count += 1
		refresh()
		return true
	return false
