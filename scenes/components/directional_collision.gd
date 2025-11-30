extends Node
class_name DirectionalCollision

## A reusable component that adjusts collision shapes based on facing direction.
## Attach as a child of any CharacterBody2D with directional sprites.

## The collision shapes to manage (will auto-find if not set)
@export var collision_shapes: Array[CollisionShape2D] = []

@export_group("Rotation")
## If true, rotates collision shapes to match facing direction
@export var rotate_with_direction: bool = true
## If true, snaps to 4 directions (UDLR). If false, rotates smoothly to any angle.
@export var snap_to_cardinal: bool = true
## If true, snaps to 8 directions. Only used if snap_to_cardinal is true.
@export var include_diagonals: bool = false

@export_group("Horizontal Offset (Left/Right)")
## Position offset when facing left or right
@export var horizontal_offset: Vector2 = Vector2.ZERO

@export_group("Vertical Offset (Up/Down)")
## Position offset when facing up or down
@export var vertical_offset: Vector2 = Vector2.ZERO

@export_group("Diagonal Offsets")
## Position offset when facing up-left or up-right
@export var diagonal_up_offset: Vector2 = Vector2.ZERO
## Position offset when facing down-left or down-right
@export var diagonal_down_offset: Vector2 = Vector2.ZERO

var _current_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# Auto-find collision shapes if none specified
	if collision_shapes.is_empty():
		_auto_find_collision_shapes()

func _auto_find_collision_shapes() -> void:
	var parent = get_parent()
	if not parent:
		return
	
	# Find direct CollisionShape2D children
	for child in parent.get_children():
		if child is CollisionShape2D:
			collision_shapes.append(child)
	
	# Find CollisionShape2D in Area2D children (like HurtArea, HitArea)
	for child in parent.get_children():
		if child is Area2D:
			for area_child in child.get_children():
				if area_child is CollisionShape2D:
					collision_shapes.append(area_child)

## Call this whenever the facing direction changes
func update_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	
	_current_direction = direction.normalized()
	_apply_rotation()
	_apply_offset()

func _apply_rotation() -> void:
	if not rotate_with_direction:
		return
	
	var target_rotation: float
	
	if snap_to_cardinal:
		target_rotation = _get_snapped_rotation()
	else:
		# Smooth rotation - capsule default is vertical, so add PI/2
		target_rotation = _current_direction.angle() + PI / 2.0
	
	for shape in collision_shapes:
		if is_instance_valid(shape):
			shape.rotation = target_rotation

func _get_snapped_rotation() -> float:
	# Capsule default orientation is vertical (0 rotation = pointing up/down)
	var dir = _current_direction
	
	if include_diagonals:
		# 8-direction snapping
		var angle = dir.angle()
		# Snap to nearest 45-degree increment
		var snapped_angle = round(angle / (PI / 4.0)) * (PI / 4.0)
		return snapped_angle + PI / 2.0
	else:
		# 4-direction snapping (UDLR)
		if abs(dir.x) > abs(dir.y):
			# Horizontal - rotate 90 degrees
			return PI / 2.0
		else:
			# Vertical - no rotation
			return 0.0

func _apply_offset() -> void:
	var target_offset = _get_offset_for_direction()
	
	for shape in collision_shapes:
		if is_instance_valid(shape):
			shape.position = target_offset

func _get_offset_for_direction() -> Vector2:
	var dir = _current_direction
	var mirror_x = dir.x < 0
	var mirror_y = dir.y < 0
	
	if include_diagonals and snap_to_cardinal:
		# Check for diagonal directions
		var is_diagonal = abs(dir.x) > 0.3 and abs(dir.y) > 0.3
		if is_diagonal:
			if mirror_y:
				return _mirror_offset(diagonal_up_offset, mirror_x, false)
			else:
				return _mirror_offset(diagonal_down_offset, mirror_x, false)
	
	# Cardinal directions
	if abs(dir.x) > abs(dir.y):
		return _mirror_offset(horizontal_offset, mirror_x, false)
	else:
		return _mirror_offset(vertical_offset, false, mirror_y)


func _mirror_offset(offset: Vector2, mirror_x: bool, mirror_y: bool) -> Vector2:
	return Vector2(
		- offset.x if mirror_x else offset.x,
		- offset.y if mirror_y else offset.y
	)

## Get the current facing direction
func get_direction() -> Vector2:
	return _current_direction
