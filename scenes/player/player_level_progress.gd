extends Resource
class_name PlayerLevelProgress

@export var level: int = 1
@export var experience: int = 0
@export var exp_table: Array = [0, 5, 10, 25, 60, 100]

var _max_level_signal_fired: bool = false

func exp_to_next_level() -> int:
	if level < exp_table.size() - 1:
		return exp_table[level] - experience
	
	return 0 # Max level reached

func add_experience(amount: int) -> void:
	experience += amount
	
	var leveled_up = false
	while level < exp_table.size() - 1 and experience >= exp_table[level]:
		level += 1
		leveled_up = true
	
	if leveled_up:
		SignalManager.player_levelled_up.emit(level, exp_to_next_level())
		
		if level == exp_table.size() - 1 and not _max_level_signal_fired:
			SignalManager.max_level_reached.emit()
			_max_level_signal_fired = true
