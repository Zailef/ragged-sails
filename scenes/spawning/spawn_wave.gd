extends Resource
class_name SpawnWave

## Defines a timed wave event - a burst of specific enemies at a specific time.

## When this wave triggers (in minutes from game start)
@export var trigger_time_minutes: float = 0.0

## Duration of the wave in seconds (enemies spawn over this period)
@export var duration_seconds: float = 5.0

## Number of enemies to spawn during this wave
@export var enemy_count: int = 10

## Specific enemies to spawn during this wave (weighted selection)
## If empty, uses the spawner's default enemy pool
@export var wave_enemies: Array[EnemySpawnEntry] = []

## Whether to spawn a boss at the end of this wave
@export var spawn_boss: bool = false

## Which enemy from wave_enemies (by index) should be the boss. -1 = random from valid entries.
@export var boss_enemy_index: int = -1

## Optional: Announcement text for UI
@export var announcement_text: String = ""

## Whether this wave has been triggered
var has_triggered: bool = false

func reset() -> void:
	has_triggered = false
