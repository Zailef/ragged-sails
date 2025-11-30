extends Node
class_name BoundaryManager

## Monitors player position relative to map boundaries and applies effects.

signal zone_changed(old_zone: String, new_zone: String)
signal zone_depth_changed(depth: float)

@export var config: MapBoundaryConfig
@export var player_path: NodePath
## Optional: If set, derives safe_zone from this sprite's bounds instead of using config.safe_zone
@export var ocean_sprite_path: NodePath
## Extra margin to inset from the ocean edge (in addition to camera viewport).
## This ensures the player can't see the edge even when at the boundary.
@export var edge_margin: float = 32.0

var player: Player
var current_zone: String = "safe"
var _damage_accumulator: float = 0.0
var _effective_safe_zone: Rect2
var _last_depth: float = 0.0

func _ready() -> void:
	if player_path:
		player = get_node(player_path) as Player
	
	if not player:
		# Try to find player in scene
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player") as Player
	
	if not player:
		push_warning("BoundaryManager: No player found!")
	
	_calculate_safe_zone()

func _calculate_safe_zone() -> void:
	if ocean_sprite_path:
		var ocean_sprite = get_node_or_null(ocean_sprite_path) as Sprite2D
		if ocean_sprite and ocean_sprite.texture:
			var ocean_rect = _get_sprite_world_rect(ocean_sprite)
			# Inset by half the viewport size + margin so camera never sees the edge
			var viewport_size = get_viewport().get_visible_rect().size
			var inset = (viewport_size / 2.0) + Vector2(edge_margin, edge_margin)
			_effective_safe_zone = ocean_rect.grow_individual(-inset.x, -inset.y, -inset.x, -inset.y)
			return
	
	# Fall back to config's safe_zone
	if config:
		_effective_safe_zone = config.safe_zone

func _get_sprite_world_rect(sprite: Sprite2D) -> Rect2:
	var texture_size = sprite.texture.get_size()
	var scaled_size = texture_size * sprite.scale
	var offset = - scaled_size / 2.0 if sprite.centered else Vector2.ZERO
	var world_pos = sprite.global_position + offset
	return Rect2(world_pos, scaled_size)

func _physics_process(delta: float) -> void:
	if not player or not config or player.is_dead:
		return
	
	var player_pos = player.global_position
	var new_zone = _get_zone_at_position(player_pos)
	
	# Emit zone changed signal
	if new_zone != current_zone:
		var old_zone = current_zone
		current_zone = new_zone
		zone_changed.emit(old_zone, new_zone)
		SignalManager.boundary_zone_changed.emit(new_zone)
	
	# Emit depth for gradual visual effects (only when changed significantly)
	var depth = _get_zone_depth(player_pos)
	if abs(depth - _last_depth) > 0.01:
		_last_depth = depth
		zone_depth_changed.emit(depth)
	
	# Apply zone effects
	match current_zone:
		"safe":
			_damage_accumulator = 0.0
		"warning":
			pass # Speed reduction is queried by player via get_speed_multiplier()
		"danger":
			_apply_danger_effects(delta)
		"death":
			_apply_death_effects()

func _apply_danger_effects(delta: float) -> void:
	if not config:
		return
	
	# Accumulate damage over time
	_damage_accumulator += config.danger_damage_per_second * delta
	
	if _damage_accumulator >= 1.0:
		var damage = int(_damage_accumulator)
		_damage_accumulator -= damage
		player.take_damage(damage)

func _apply_death_effects() -> void:
	if config.instant_death_enabled:
		# Deal massive damage to kill player
		player.take_damage(player.max_health * 10)

## Get the speed multiplier for the player's current zone
func get_speed_multiplier() -> float:
	if not config:
		return 1.0
	
	match current_zone:
		"warning":
			return config.warning_speed_multiplier
		"danger":
			return config.danger_speed_multiplier
		"death":
			return 0.0
		_:
			return 1.0

## Get the current zone name
func get_current_zone() -> String:
	return current_zone

## Check if player is in a dangerous zone
func is_in_danger() -> bool:
	return current_zone == "danger" or current_zone == "death"

## Get the effective safe zone (may be calculated from ocean sprite)
func get_effective_safe_zone() -> Rect2:
	return _effective_safe_zone

## Returns what zone the position is in using effective safe zone
func _get_zone_at_position(pos: Vector2) -> String:
	if _effective_safe_zone.has_point(pos):
		return "safe"
	elif _effective_safe_zone.grow(config.warning_zone_width).has_point(pos):
		return "warning"
	elif _effective_safe_zone.grow(config.warning_zone_width + config.danger_zone_width).has_point(pos):
		return "danger"
	else:
		return "death"

## Returns depth using effective safe zone
func _get_zone_depth(pos: Vector2) -> float:
	if _effective_safe_zone.has_point(pos):
		return 0.0
	
	var clamped = Vector2(
		clampf(pos.x, _effective_safe_zone.position.x, _effective_safe_zone.end.x),
		clampf(pos.y, _effective_safe_zone.position.y, _effective_safe_zone.end.y)
	)
	var distance_from_safe = pos.distance_to(clamped)
	var total_danger_width = config.warning_zone_width + config.danger_zone_width
	return clampf(distance_from_safe / total_danger_width, 0.0, 1.0)
