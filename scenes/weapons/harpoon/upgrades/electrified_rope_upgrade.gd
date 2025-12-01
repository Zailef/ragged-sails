## Electrifies the harpoon rope, dealing damage to enemies that touch it.
extends WeaponUpgrade
class_name ElectrifiedRopeUpgrade

## Damage dealt per tick to enemies touching the rope
@export var damage_per_tick: int = 5

## Time between damage ticks
@export var tick_rate: float = 0.25

## Visual effect color for the electrified rope
@export var electricity_color: Color = Color(0.5, 0.8, 1.0)

var _tick_timer: float = 0.0
var _enemies_on_rope: Array[Enemy] = []


func _init() -> void:
	id = &"electrified_rope"
	display_name = "Electrified Rope"
	description = "The harpoon rope crackles with electricity, damaging enemies that touch it."


func on_unlock(weapon: BaseWeapon) -> void:
	# Apply visual effect to rope
	var rope = weapon.get_node_or_null("Line2D") as Line2D
	if rope:
		rope.default_color = electricity_color


func on_physics_process(weapon: BaseWeapon, delta: float) -> void:
	# Only process when weapon is active and has a visible rope
	var rope = weapon.get_node_or_null("Line2D") as Line2D
	if not rope or not rope.visible or rope.points.size() < 2:
		_enemies_on_rope.clear()
		return
	
	# Find enemies intersecting the rope line
	_update_enemies_on_rope(weapon, rope)
	
	# Apply damage on tick
	_tick_timer += delta
	if _tick_timer >= tick_rate:
		_tick_timer = 0.0
		_apply_rope_damage()


func on_reset(_weapon: BaseWeapon) -> void:
	_tick_timer = 0.0
	_enemies_on_rope.clear()


func _update_enemies_on_rope(weapon: BaseWeapon, rope: Line2D) -> void:
	_enemies_on_rope.clear()
	
	# Get rope endpoints in global coordinates
	var start = rope.to_global(rope.points[0])
	var end = rope.to_global(rope.points[1])
	
	# Check all enemies
	var enemies = weapon.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Enemy and is_instance_valid(enemy):
			# Simple distance-to-line check
			if _point_near_line(enemy.global_position, start, end, 20.0):
				_enemies_on_rope.append(enemy)


func _point_near_line(point: Vector2, line_start: Vector2, line_end: Vector2, threshold: float) -> bool:
	var line_vec = line_end - line_start
	var line_length = line_vec.length()
	if line_length < 0.001:
		return point.distance_to(line_start) <= threshold
	
	var line_dir = line_vec / line_length
	var point_vec = point - line_start
	var projection = point_vec.dot(line_dir)
	
	# Check if projection is within line segment
	if projection < 0 or projection > line_length:
		return false
	
	# Calculate perpendicular distance
	var closest_point = line_start + line_dir * projection
	return point.distance_to(closest_point) <= threshold


func _apply_rope_damage() -> void:
	for enemy in _enemies_on_rope:
		if is_instance_valid(enemy):
			enemy.take_damage(damage_per_tick)
