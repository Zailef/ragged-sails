## Manages status effects for any entity (Enemy, Player, etc.)
## Add as a child node to any entity that can receive status effects.
extends Node
class_name StatusEffectManager

signal effect_applied(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)
signal effect_stacked(effect: StatusEffect, stack_count: int)

var active_effects: Array[StatusEffectInstance] = []

## The entity this manager belongs to (set automatically in _ready)
var entity: Node

func _ready() -> void:
	entity = get_parent()
	# Clean up effects when the entity is about to be removed from the tree
	entity.tree_exiting.connect(_on_entity_tree_exiting)

func _on_entity_tree_exiting() -> void:
	# Notify all effect sources that this entity is being freed
	# This allows weapons like the trident to remove this enemy from their tracking
	for instance in active_effects:
		for source in instance.sources:
			if is_instance_valid(source) and source.has_method("_on_affected_entity_freed"):
				source._on_affected_entity_freed(entity)
	active_effects.clear()

func _process(delta: float) -> void:
	_process_effects(delta)

## Applies a status effect to this entity
func apply_effect(effect: StatusEffect, source: Node = null) -> void:
	# Check if this effect type already exists
	for instance in active_effects:
		if instance.effect.id == effect.id:
			# Track this source even if effect already exists
			instance.add_source(source)
			if effect.can_stack:
				if instance.add_stack():
					effect_stacked.emit(effect, instance.stack_count)
			else:
				# Refresh duration instead of stacking
				instance.refresh()
			return

	# Add new effect
	var instance = StatusEffectInstance.new(effect, source)
	active_effects.append(instance)
	effect.on_apply(entity)
	effect_applied.emit(effect)

## Removes all instances of a status effect by id
func remove_effect(effect_id: StringName) -> void:
	var to_remove: Array[StatusEffectInstance] = []
	for instance in active_effects:
		if instance.effect.id == effect_id:
			instance.effect.on_remove(entity)
			effect_removed.emit(instance.effect)
			to_remove.append(instance)

	for instance in to_remove:
		active_effects.erase(instance)

## Removes all status effects from a specific source
## Only fully removes the effect if this was the last source tracking it
func remove_effects_from_source(source: Node) -> void:
	var to_remove: Array[StatusEffectInstance] = []
	for instance in active_effects:
		if instance.has_source(source):
			# Remove this source; if it was the last one, remove the effect entirely
			if instance.remove_source(source):
				instance.effect.on_remove(entity)
				effect_removed.emit(instance.effect)
				to_remove.append(instance)

	for instance in to_remove:
		active_effects.erase(instance)

## Removes all active status effects
func clear_all_effects() -> void:
	for instance in active_effects:
		instance.effect.on_remove(entity)
		effect_removed.emit(instance.effect)
	active_effects.clear()

## Checks if entity has a specific status effect
func has_effect(effect_id: StringName) -> bool:
	for instance in active_effects:
		if instance.effect.id == effect_id:
			return true
	return false

## Gets the stack count for a specific effect (0 if not present)
func get_stack_count(effect_id: StringName) -> int:
	for instance in active_effects:
		if instance.effect.id == effect_id:
			return instance.stack_count
	return 0

## Gets the combined speed multiplier from all active effects
func get_speed_multiplier() -> float:
	var multiplier = 1.0
	for instance in active_effects:
		var effect_multiplier = instance.effect.get_speed_multiplier()
		# Apply stacking
		for i in range(instance.stack_count):
			multiplier *= effect_multiplier
	return multiplier

## Gets the combined damage taken multiplier from all active effects
func get_damage_taken_multiplier() -> float:
	var multiplier = 1.0
	for instance in active_effects:
		var effect_multiplier = instance.effect.get_damage_taken_multiplier()
		for i in range(instance.stack_count):
			multiplier *= effect_multiplier
	return multiplier

## Gets the combined damage dealt multiplier from all active effects
func get_damage_dealt_multiplier() -> float:
	var multiplier = 1.0
	for instance in active_effects:
		var effect_multiplier = instance.effect.get_damage_dealt_multiplier()
		for i in range(instance.stack_count):
			multiplier *= effect_multiplier
	return multiplier

## Processes all active status effects (called every frame)
func _process_effects(delta: float) -> void:
	var to_remove: Array[StatusEffectInstance] = []

	for instance in active_effects:
		# Call tick on the effect for any per-frame logic
		instance.effect.on_tick(entity, delta)

		# Update duration and check for expiry
		if not instance.tick(delta):
			instance.effect.on_remove(entity)
			effect_removed.emit(instance.effect)
			to_remove.append(instance)

	for instance in to_remove:
		active_effects.erase(instance)
