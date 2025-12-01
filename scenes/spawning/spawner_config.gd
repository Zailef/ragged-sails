extends Resource
class_name SpawnerConfig

## Main configuration for the enemy spawner system.
## Uses curves to control spawn rate and difficulty scaling over time.

@export_group("Enemy Pool")
## Default enemies that can spawn (weighted random selection)
@export var enemy_pool: Array[EnemySpawnEntry] = []

@export_group("Spawn Rate")
## Base time between spawns in seconds (at game start)
@export var base_spawn_interval: float = 2.0

## Minimum spawn interval (fastest spawning)
@export var min_spawn_interval: float = 0.3

## Curve controlling spawn rate over time (0.0 = start, 1.0 = max time)
## Y-axis is a multiplier on base_spawn_interval (lower = faster spawning)
## Example: curve starting at 1.0 and ending at 0.2 means 5x faster spawning at end
@export var spawn_rate_curve: Curve

@export_group("Enemy Count")
## Base number of enemies to spawn per interval
@export var base_enemies_per_spawn: int = 1

## Maximum enemies to spawn per interval
@export var max_enemies_per_spawn: int = 5

## Curve controlling enemies per spawn over time
## Y-axis is a multiplier (1.0 = base, 2.0 = double, etc.)
@export var enemies_per_spawn_curve: Curve

@export_group("Boss Spawning")
## Time in minutes before the first boss can spawn
@export var first_boss_time_minutes: float = 1.0

## Base time between boss spawns in seconds
@export var base_boss_spawn_interval: float = 60.0

## Minimum boss spawn interval (fastest boss spawning)
@export var min_boss_spawn_interval: float = 20.0

## Curve controlling boss spawn rate over time (lower = faster)
@export var boss_spawn_rate_curve: Curve

@export_group("Difficulty Scaling")
## Maximum game duration in minutes (used for curve sampling)
@export var max_game_time_minutes: float = 30.0

## Enemy stat multiplier curve over time (health, damage, etc.)
## Y-axis is the multiplier applied to enemy stats
@export var difficulty_curve: Curve

@export_group("Limits")
## Maximum number of enemies alive at once (0 = no limit)
@export var max_enemies_alive: int = 100

## Spawn margin - distance outside screen edge where enemies spawn
@export var spawn_margin: float = 50.0

@export_group("Waves")
## Timed wave events (optional, for special moments)
@export var waves: Array[SpawnWave] = []

## Get spawn interval at current time progress
func get_spawn_interval(time_progress: float) -> float:
	var multiplier = 1.0
	if spawn_rate_curve:
		multiplier = spawn_rate_curve.sample(time_progress)
	return maxf(base_spawn_interval * multiplier, min_spawn_interval)

## Get number of enemies to spawn at current time progress
func get_enemies_per_spawn(time_progress: float) -> int:
	var multiplier = 1.0
	if enemies_per_spawn_curve:
		multiplier = enemies_per_spawn_curve.sample(time_progress)
	return clampi(int(base_enemies_per_spawn * multiplier), 1, max_enemies_per_spawn)

## Get boss spawn interval at current time progress
func get_boss_spawn_interval(time_progress: float) -> float:
	var multiplier = 1.0
	if boss_spawn_rate_curve:
		multiplier = boss_spawn_rate_curve.sample(time_progress)
	return maxf(base_boss_spawn_interval * multiplier, min_boss_spawn_interval)

## Get difficulty multiplier at current time progress
func get_difficulty_multiplier(time_progress: float) -> float:
	if difficulty_curve:
		return difficulty_curve.sample(time_progress)
	return 1.0

## Reset all waves for a new game
func reset_waves() -> void:
	for wave in waves:
		wave.reset()
