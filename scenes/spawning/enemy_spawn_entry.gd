extends Resource
class_name EnemySpawnEntry

## Defines an enemy type that can be spawned, with weight and time constraints.

@export var enemy_scene: PackedScene

## Base spawn weight - higher values mean more likely to be picked
@export var base_weight: float = 1.0

## Minimum game time (in minutes) before this enemy can spawn. 0 = available from start.
@export var min_time_minutes: float = 0.0

## Maximum game time (in minutes) this enemy can spawn until. -1 = no limit.
@export var max_time_minutes: float = -1.0

## Optional: Curve to modify spawn weight over time (0.0 = game start, 1.0 = max game time)
## If null, base_weight is used directly
@export var weight_over_time: Curve

## Whether this enemy can be spawned as a boss variant
@export var can_be_boss: bool = true

## Get the effective weight at a given time progress (0.0 to 1.0)
func get_weight_at_time(time_progress: float, elapsed_minutes: float) -> float:
	# Check time constraints
	if elapsed_minutes < min_time_minutes:
		return 0.0
	if max_time_minutes >= 0.0 and elapsed_minutes > max_time_minutes:
		return 0.0
	
	# Apply weight curve if available
	if weight_over_time:
		return base_weight * weight_over_time.sample(time_progress)
	
	return base_weight

## Check if this enemy can spawn at the given time
func can_spawn_at_time(elapsed_minutes: float) -> bool:
	if elapsed_minutes < min_time_minutes:
		return false
	if max_time_minutes >= 0.0 and elapsed_minutes > max_time_minutes:
		return false
	return true
