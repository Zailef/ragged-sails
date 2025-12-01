extends Node
class_name EnemySpawner

## Handles enemy spawning based on SpawnerConfig, using curves for scaling.

signal enemy_spawned(enemy: Enemy)
signal wave_started(wave: SpawnWave)
signal wave_completed(wave: SpawnWave)
signal boss_spawned(boss: Enemy)

@export var config: SpawnerConfig
@export var enemies_container: Node

var _spawn_timer: float = 0.0
var _boss_spawn_timer: float = 0.0
var _first_boss_spawned: bool = false
var _active_wave: SpawnWave = null
var _wave_timer: float = 0.0
var _wave_enemies_spawned: int = 0
var _current_enemy_count: int = 0

func _ready() -> void:
	if not config:
		push_warning("EnemySpawner: No SpawnerConfig assigned!")
		return
	
	GameClock.game_started.connect(_on_game_started)
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)

func _process(delta: float) -> void:
	if not GameClock.is_running or not config:
		return
	
	var time_progress = GameClock.get_time_progress(config.max_game_time_minutes)
	
	_handle_continuous_spawning(delta, time_progress)
	_handle_boss_spawning(delta, time_progress)
	_handle_wave_spawning(delta, time_progress)
	_check_wave_triggers()

func _handle_continuous_spawning(delta: float, time_progress: float) -> void:
	_spawn_timer += delta
	
	var spawn_interval = config.get_spawn_interval(time_progress)
	
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		
		if _can_spawn_more():
			var enemies_to_spawn = config.get_enemies_per_spawn(time_progress)
			for i in enemies_to_spawn:
				if _can_spawn_more():
					_spawn_enemy_from_pool(config.enemy_pool, time_progress)

func _handle_boss_spawning(delta: float, time_progress: float) -> void:
	var elapsed_minutes = GameClock.elapsed_time / 60.0
	
	# Don't spawn bosses before the configured first boss time
	if elapsed_minutes < config.first_boss_time_minutes:
		_boss_spawn_timer = 0.0
		return
	
	# Spawn first boss immediately when first_boss_time is reached
	if not _first_boss_spawned:
		_first_boss_spawned = true
		_spawn_boss()
		return
	
	_boss_spawn_timer += delta
	
	var boss_interval = config.get_boss_spawn_interval(time_progress)
	
	if _boss_spawn_timer >= boss_interval:
		_boss_spawn_timer = 0.0
		_spawn_boss()

func _spawn_boss() -> void:
	var time_progress = GameClock.get_time_progress(config.max_game_time_minutes)
	
	# Select a random valid boss from the enemy pool
	var valid_entries: Array[EnemySpawnEntry] = []
	for entry in config.enemy_pool:
		if entry.can_be_boss and entry.can_spawn_at_time(GameClock.elapsed_minutes):
			valid_entries.append(entry)
	
	if valid_entries.size() == 0:
		return
	
	var entry = valid_entries[randi() % valid_entries.size()]
	var boss = _spawn_enemy(entry, true, time_progress)
	if boss:
		boss_spawned.emit(boss)

func _handle_wave_spawning(delta: float, time_progress: float) -> void:
	if not _active_wave:
		return
	
	_wave_timer += delta
	
	if _active_wave.enemy_count <= 0:
		_complete_wave()
		return
	
	var enemies_remaining = _active_wave.enemy_count - _wave_enemies_spawned
	if enemies_remaining <= 0:
		_complete_wave()
		return
	
	# Spread enemy spawns evenly across wave duration
	var spawn_interval = _active_wave.duration_seconds / float(_active_wave.enemy_count)
	var expected_spawns = int(_wave_timer / spawn_interval)
	
	while _wave_enemies_spawned < expected_spawns and _wave_enemies_spawned < _active_wave.enemy_count:
		if _can_spawn_more():
			var pool = _active_wave.wave_enemies if _active_wave.wave_enemies.size() > 0 else config.enemy_pool
			_spawn_enemy_from_pool(pool, time_progress)
			_wave_enemies_spawned += 1

func _check_wave_triggers() -> void:
	if _active_wave:
		return
	
	var elapsed_minutes = GameClock.elapsed_time / 60.0
	
	for wave in config.waves:
		if not wave.has_triggered and elapsed_minutes >= wave.trigger_time_minutes:
			_start_wave(wave)
			break

func _start_wave(wave: SpawnWave) -> void:
	wave.has_triggered = true
	_active_wave = wave
	_wave_timer = 0.0
	_wave_enemies_spawned = 0
	wave_started.emit(wave)
	# Emit wave announcement if text is provided
	if wave.announcement_text != "":
		SignalManager.wave_announced.emit(wave.announcement_text)

func _complete_wave() -> void:
	var completed_wave = _active_wave
	_active_wave = null
	
	# Spawn boss at end of wave if configured
	if completed_wave.spawn_boss:
		_spawn_wave_boss(completed_wave)
	
	wave_completed.emit(completed_wave)

func _spawn_wave_boss(wave: SpawnWave) -> void:
	var time_progress = GameClock.get_time_progress(config.max_game_time_minutes)
	var pool = wave.wave_enemies if wave.wave_enemies.size() > 0 else config.enemy_pool
	
	var entry: EnemySpawnEntry = null
	
	# Use specific boss_enemy_index if valid, otherwise pick random valid boss
	if wave.boss_enemy_index >= 0 and wave.boss_enemy_index < pool.size():
		entry = pool[wave.boss_enemy_index]
	else:
		# Pick random valid boss from pool
		var valid_entries: Array[EnemySpawnEntry] = []
		for e in pool:
			if e.can_be_boss:
				valid_entries.append(e)
		if valid_entries.size() > 0:
			entry = valid_entries[randi() % valid_entries.size()]
	
	if entry:
		var boss = _spawn_enemy(entry, true, time_progress)
		if boss:
			boss_spawned.emit(boss)

func _spawn_enemy_from_pool(pool: Array[EnemySpawnEntry], time_progress: float) -> Enemy:
	var entry = _select_weighted_enemy(pool, time_progress)
	if not entry:
		return null
	
	return _spawn_enemy(entry, false, time_progress)

func _spawn_enemy(entry: EnemySpawnEntry, as_boss: bool, time_progress: float) -> Enemy:
	if not entry or not entry.enemy_scene:
		return null
	
	var enemy: Enemy = entry.enemy_scene.instantiate() as Enemy
	if not enemy:
		push_error("EnemySpawner: Failed to instantiate enemy from scene")
		return null
	
	enemy.global_position = _get_spawn_position()
	enemy.is_boss = as_boss
	enemy.difficulty_multiplier = config.get_difficulty_multiplier(time_progress)
	
	_get_enemies_container().add_child(enemy)
	_current_enemy_count += 1
	enemy_spawned.emit(enemy)
	
	return enemy

func _select_weighted_enemy(pool: Array[EnemySpawnEntry], time_progress: float) -> EnemySpawnEntry:
	if pool.size() == 0:
		return null
	
	var elapsed_minutes = GameClock.elapsed_time / 60.0
	var total_weight: float = 0.0
	var valid_entries: Array[Dictionary] = []
	
	for entry in pool:
		var weight = entry.get_weight_at_time(time_progress, elapsed_minutes)
		if weight > 0.0:
			valid_entries.append({"entry": entry, "weight": weight})
			total_weight += weight
	
	if valid_entries.size() == 0:
		return null
	
	var roll = randf() * total_weight
	var cumulative: float = 0.0
	
	for data in valid_entries:
		cumulative += data.weight
		if roll <= cumulative:
			return data.entry
	
	return valid_entries[valid_entries.size() - 1].entry

func _get_spawn_position() -> Vector2:
	var viewport = get_viewport()
	if not viewport:
		return Vector2.ZERO
	
	var viewport_rect = viewport.get_visible_rect()
	var camera = viewport.get_camera_2d()
	
	if not camera:
		return Vector2.ZERO
	
	var camera_pos = camera.get_screen_center_position()
	var screen_size = viewport_rect.size / camera.zoom # Account for camera zoom
	var margin = config.spawn_margin if config else 50.0
	
	# Try up to 5 times to find a valid spawn position
	for _attempt in range(5):
		var edge = randi() % 4
		var spawn_pos = Vector2.ZERO
		
		match edge:
			0: # Top
				spawn_pos.x = camera_pos.x + randf_range(-screen_size.x / 2, screen_size.x / 2)
				spawn_pos.y = camera_pos.y - screen_size.y / 2 - margin
			1: # Right
				spawn_pos.x = camera_pos.x + screen_size.x / 2 + margin
				spawn_pos.y = camera_pos.y + randf_range(-screen_size.y / 2, screen_size.y / 2)
			2: # Bottom
				spawn_pos.x = camera_pos.x + randf_range(-screen_size.x / 2, screen_size.x / 2)
				spawn_pos.y = camera_pos.y + screen_size.y / 2 + margin
			3: # Left
				spawn_pos.x = camera_pos.x - screen_size.x / 2 - margin
				spawn_pos.y = camera_pos.y + randf_range(-screen_size.y / 2, screen_size.y / 2)
		
		if _is_spawn_position_valid(spawn_pos):
			return spawn_pos
	
	# Fallback: return the last attempted position even if invalid
	return camera_pos + Vector2(screen_size.x / 2 + margin, 0)


func _is_spawn_position_valid(pos: Vector2) -> bool:
	var space_state = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 # World/obstacle layer
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query, 1)
	return results.is_empty()

func _can_spawn_more() -> bool:
	if config.max_enemies_alive <= 0:
		return true
	return _current_enemy_count < config.max_enemies_alive

func _get_enemies_container() -> Node:
	if enemies_container:
		return enemies_container
	
	# Fallback: try to find an "Enemies" node in the current scene
	var scene = get_tree().get_current_scene()
	if scene and scene.has_node("Enemies"):
		return scene.get_node("Enemies")
	
	# Last resort: use current scene
	return scene

func _on_game_started() -> void:
	_spawn_timer = 0.0
	_boss_spawn_timer = 0.0
	_first_boss_spawned = false
	_current_enemy_count = 0
	_active_wave = null
	if config:
		config.reset_waves()

func _on_enemy_defeated() -> void:
	_current_enemy_count = maxi(0, _current_enemy_count - 1)
