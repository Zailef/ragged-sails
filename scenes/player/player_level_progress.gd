extends Resource
class_name PlayerLevelProgress

const MAX_LEVEL: int = 99

## Curve that maps level (0-1) to XP multiplier (0-1)
## X-axis: level progress (0 = level 1, 1 = max level)
## Y-axis: XP requirement multiplier (0 = min_exp, 1 = max_exp)
@export var level_curve: Curve

## Minimum XP required (at level 2)
@export var min_exp: int = 5
## Maximum XP required (at max level)  
@export var max_exp: int = 100

@export var level: int = 1
@export var experience: int = 0

var _exp_table: Array[int] = []
var _max_level_signal_fired: bool = false


func _init() -> void:
	_generate_exp_table()


func _generate_exp_table() -> void:
	_exp_table.clear()
	_exp_table.append(0) # Level 1 requires 0 XP
	
	var cumulative: int = 0
	for lvl in range(1, MAX_LEVEL + 1):
		var t: float = float(lvl - 1) / float(MAX_LEVEL - 1) # 0 to 1
		var curve_value: float = level_curve.sample(t) if level_curve else t
		var level_exp: int = int(lerp(float(min_exp), float(max_exp), curve_value))
		cumulative += level_exp
		_exp_table.append(cumulative)


func get_exp_for_level(lvl: int) -> int:
	if lvl < 0 or lvl >= _exp_table.size():
		return 0
	return _exp_table[lvl]


func exp_to_next_level() -> int:
	if level < MAX_LEVEL:
		return _exp_table[level] - experience
	return 0 # Max level reached


func add_experience(amount: int) -> void:
	experience += amount

	var leveled_up = false
	while level < MAX_LEVEL and experience >= _exp_table[level]:
		level += 1
		leveled_up = true

	if leveled_up:
		SignalManager.player_levelled_up.emit(level, exp_to_next_level())

		if level >= MAX_LEVEL and not _max_level_signal_fired:
			SignalManager.max_level_reached.emit()
			_max_level_signal_fired = true
