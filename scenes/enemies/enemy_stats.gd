extends Resource
class_name EnemyStats

@export_group("Base Stats")
@export var name: StringName
@export var move_speed: float = 40.0
@export var max_health: int = 100
@export var damage: int = 10
@export var damage_rate: float = 1.0

@export_group("Boss Multipliers")
@export var boss_speed_multiplier: float = 0.9
@export var boss_health_multiplier: float = 3.0
@export var boss_damage_multiplier: float = 2.0
@export var boss_damage_rate_multiplier: float = 1.2
@export var boss_scale_multiplier: float = 1.3

func get_move_speed(is_boss: bool) -> float:
	return move_speed * (boss_speed_multiplier if is_boss else 1.0)

func get_max_health(is_boss: bool) -> int:
	return int(max_health * (boss_health_multiplier if is_boss else 1.0))

func get_damage(is_boss: bool) -> int:
	return int(damage * (boss_damage_multiplier if is_boss else 1.0))

func get_damage_rate(is_boss: bool) -> float:
	return damage_rate * (boss_damage_rate_multiplier if is_boss else 1.0)

func get_scale(is_boss: bool) -> float:
	return boss_scale_multiplier if is_boss else 1.0
