## Chain Lightning - Electricity arcs from the pinned enemy to nearby enemies.
extends WeaponUpgrade
class_name ChainLightningUpgrade

## Damage dealt per arc tick
@export var arc_damage: int = 3

## Time between arc damage ticks
@export var arc_tick_rate: float = 0.5

## Maximum distance for chain lightning to arc
@export var arc_range: float = 80.0

## Maximum number of enemies to chain to
@export var max_chains: int = 3

var _arc_timer: float = 0.0


func _init() -> void:
	id = &"chain_lightning"
	display_name = "Chain Lightning"
	description = "Electricity arcs from pinned enemies to nearby foes."


func on_physics_process(weapon: BaseWeapon, delta: float) -> void:
	var harpoon := weapon as Harpoon
	if not harpoon or not harpoon.is_pinned:
		_arc_timer = 0.0
		return
	
	if not is_instance_valid(harpoon.target):
		return
	
	_arc_timer += delta
	if _arc_timer >= arc_tick_rate:
		_arc_timer = 0.0
		_apply_chain_damage(weapon, harpoon.target)


func on_reset(_weapon: BaseWeapon) -> void:
	_arc_timer = 0.0


func _apply_chain_damage(weapon: BaseWeapon, pinned_enemy: Enemy) -> void:
	var enemies = weapon.get_tree().get_nodes_in_group("enemies")
	var chains_applied := 0
	
	for enemy in enemies:
		if chains_applied >= max_chains:
			break
		
		if enemy == pinned_enemy:
			continue
		
		if not enemy is Enemy or not is_instance_valid(enemy):
			continue
		
		var distance = enemy.global_position.distance_to(pinned_enemy.global_position)
		if distance <= arc_range:
			enemy.take_damage(arc_damage)
			chains_applied += 1
