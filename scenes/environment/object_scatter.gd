extends Node
class_name ObjectScatter

## Scatters environmental objects (rocks, shipwrecks, etc.) across the play area.

signal scatter_complete(object_count: int)

@export var config: ScatterConfig

## Path to the BoundaryManager to get the play area bounds
@export var boundary_manager_path: NodePath

## Path to the player node to avoid spawning near player start
@export var player_path: NodePath

## Container node for spawned objects (if not set, uses parent)
@export var objects_container: Node

var _boundary_manager: BoundaryManager
var _player: Node2D
var _spawned_positions: Array[Vector2] = []
var _spawned_objects: Array[Node2D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if boundary_manager_path:
		_boundary_manager = get_node_or_null(boundary_manager_path) as BoundaryManager
	
	if player_path:
		_player = get_node_or_null(player_path) as Node2D
	
	# Wait a frame for boundary manager to calculate its zone
	await get_tree().process_frame
	
	scatter_objects()


func scatter_objects() -> void:
	if not config or config.entries.is_empty():
		push_warning("ObjectScatter: No config or entries defined!")
		return
	
	# Initialize RNG
	if config.random_seed != 0:
		_rng.seed = config.random_seed
	else:
		_rng.randomize()
	
	_spawned_positions.clear()
	_spawned_objects.clear()
	var total_spawned := 0
	
	var spawn_area := _get_spawn_area()
	if spawn_area.size == Vector2.ZERO:
		push_warning("ObjectScatter: Could not determine spawn area!")
		return
	
	print("ObjectScatter: Spawn area = ", spawn_area, " (size: ", spawn_area.size, ")")
	
	var player_start := _get_player_start_position()
	
	# Calculate density multiplier based on area size
	var area_size := spawn_area.size.x * spawn_area.size.y
	var density_multiplier := area_size / (1000.0 * 1000.0) # How many 1000x1000 areas fit
	print("ObjectScatter: Area = ", area_size, " sq pixels, density multiplier = ", density_multiplier)
	
	# Process each entry
	for entry in config.entries:
		if not entry or not entry.scene:
			continue
		
		var count: int
		if config.use_density_spawning:
			# Scale count based on area size
			var base_count := config.objects_per_1000_sq * density_multiplier
			# Apply entry weight and add some randomness
			var target := base_count * entry.weight
			count = clampi(int(target * _rng.randf_range(0.8, 1.2)), entry.min_count, entry.max_count)
		else:
			count = _rng.randi_range(entry.min_count, entry.max_count)
		
		print("ObjectScatter: Spawning ", count, " of ", entry.scene.resource_path.get_file())
		var spawned_for_entry := 0
		
		# Decide how many should be in clusters
		var cluster_spawns := 0
		if config.enable_clustering:
			for i in count:
				if _rng.randf() < config.cluster_chance:
					cluster_spawns += 1
		
		var solo_spawns := count - cluster_spawns
		
		# Spawn solo objects
		for i in solo_spawns:
			var pos := _find_valid_position(spawn_area, entry, player_start)
			if pos != Vector2.INF:
				_spawn_object(entry, pos)
				spawned_for_entry += 1
		
		# Spawn clusters
		while cluster_spawns > 0:
			var cluster_size := mini(_rng.randi_range(config.min_cluster_size, config.max_cluster_size), cluster_spawns)
			var cluster_center := _find_valid_position(spawn_area, entry, player_start)
			
			if cluster_center != Vector2.INF:
				# Spawn objects around cluster center
				for i in cluster_size:
					var offset := Vector2(
						_rng.randf_range(-config.cluster_radius, config.cluster_radius),
						_rng.randf_range(-config.cluster_radius, config.cluster_radius)
					)
					var cluster_pos := cluster_center + offset
					
					# Validate cluster position
					if _is_position_valid(cluster_pos, spawn_area, entry, player_start):
						_spawn_object(entry, cluster_pos)
						spawned_for_entry += 1
						cluster_spawns -= 1
				# If we didn't spawn any in this cluster attempt, still decrement to avoid infinite loop
				if cluster_size > 0 and cluster_spawns >= cluster_size:
					cluster_spawns -= cluster_size
			else:
				# Couldn't find cluster center, skip remaining
				cluster_spawns = 0
		
		total_spawned += spawned_for_entry
	
	print("ObjectScatter: Spawned ", total_spawned, " objects")
	scatter_complete.emit(total_spawned)


func _get_spawn_area() -> Rect2:
	if _boundary_manager:
		var safe_zone := _boundary_manager.get_effective_safe_zone()
		# Shrink by margin
		return safe_zone.grow(-config.boundary_margin)
	
	# Fallback to a default area
	return Rect2(-500, -500, 1000, 1000)


func _get_player_start_position() -> Vector2:
	if _player:
		return _player.global_position
	return Vector2.ZERO


func _find_valid_position(spawn_area: Rect2, entry: ScatterEntry, player_start: Vector2) -> Vector2:
	for attempt in config.max_placement_attempts:
		var pos := Vector2(
			_rng.randf_range(spawn_area.position.x, spawn_area.end.x),
			_rng.randf_range(spawn_area.position.y, spawn_area.end.y)
		)
		
		if _is_position_valid(pos, spawn_area, entry, player_start):
			return pos
	
	return Vector2.INF


func _is_position_valid(pos: Vector2, spawn_area: Rect2, entry: ScatterEntry, player_start: Vector2) -> bool:
	# Check if within spawn area
	if not spawn_area.has_point(pos):
		return false
	
	# Check player start exclusion
	if not entry.allow_near_player_start:
		if pos.distance_to(player_start) < entry.player_start_exclusion_radius:
			return false
	
	# Check spacing from other objects
	var min_dist := maxf(entry.min_spacing, config.global_min_spacing)
	for existing_pos in _spawned_positions:
		if pos.distance_to(existing_pos) < min_dist:
			return false
	
	return true


func _spawn_object(entry: ScatterEntry, pos: Vector2) -> void:
	var obj: Node2D = entry.scene.instantiate() as Node2D
	if not obj:
		push_error("ObjectScatter: Failed to instantiate scene as Node2D")
		return
	
	obj.global_position = pos
	
	# Apply random transformations
	if entry.random_rotation:
		obj.rotation = _rng.randf_range(0, TAU)
	
	if entry.random_scale:
		var scale_factor := _rng.randf_range(entry.min_scale, entry.max_scale)
		obj.scale *= scale_factor
	
	# Handle flipping (for Sprite2D children or if object is a Sprite2D)
	_apply_random_flip(obj, entry)
	
	_get_container().add_child(obj)
	_spawned_positions.append(pos)
	_spawned_objects.append(obj)


func _apply_random_flip(obj: Node2D, entry: ScatterEntry) -> void:
	var flip_h := entry.random_flip_h and _rng.randf() > 0.5
	var flip_v := entry.random_flip_v and _rng.randf() > 0.5
	
	if not flip_h and not flip_v:
		return
	
	# If the object itself is a Sprite2D
	if obj is Sprite2D:
		var sprite := obj as Sprite2D
		if flip_h:
			sprite.flip_h = not sprite.flip_h
		if flip_v:
			sprite.flip_v = not sprite.flip_v
		return
	
	# Otherwise, apply to scale (works for any Node2D)
	if flip_h:
		obj.scale.x *= -1
	if flip_v:
		obj.scale.y *= -1


func _get_container() -> Node:
	if objects_container:
		return objects_container
	return get_parent()


## Clears all scattered objects and re-scatters
func reshuffle() -> void:
	# Remove only the objects we spawned
	for obj in _spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	_spawned_objects.clear()
	_spawned_positions.clear()
	
	await get_tree().process_frame
	scatter_objects()


## Get count of spawned objects
func get_spawned_count() -> int:
	return _spawned_positions.size()
