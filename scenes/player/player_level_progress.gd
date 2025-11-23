extends Resource
class_name PlayerLevelProgress

var level: int = 1
var experience: int = 0

var exp_table: Array = [0, 5, 10, 25, 60, 100]

func exp_to_next_level() -> int:
	if level < exp_table.size():
		return exp_table[level] - experience
	return 0

func add_experience(amount: int) -> void:
	experience += amount
	while level < exp_table.size() - 1 and experience >= exp_table[level]:
		level += 1
		SignalManager.player_levelled_up.emit(level, exp_to_next_level())
