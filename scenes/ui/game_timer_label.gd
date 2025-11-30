extends Label
class_name GameTimerLabel

## Displays the current game time from GameClock.

func _ready() -> void:
	GameClock.second_passed.connect(_on_second_passed)
	_update_display()

func _on_second_passed(_elapsed_seconds: int) -> void:
	_update_display()

func _update_display() -> void:
	text = GameClock.get_formatted_time()
