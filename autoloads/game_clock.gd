extends Node
class_name GameClockSingleton

## Global game clock for tracking elapsed time and triggering time-based events.
## Use GameClock.elapsed_time to get current game time in seconds.
## Use GameClock.elapsed_minutes for convenience.

signal second_passed(elapsed_seconds: int)
signal minute_passed(elapsed_minutes: int)
signal game_started
signal game_paused
signal game_resumed

var elapsed_time: float = 0.0
var elapsed_minutes: int = 0
var is_running: bool = false

var _last_second: int = 0
var _last_minute: int = 0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if not is_running:
		return
	
	elapsed_time += delta
	
	var current_second = int(elapsed_time)
	if current_second > _last_second:
		_last_second = current_second
		second_passed.emit(current_second)
	
	var current_minute = int(elapsed_time / 60.0)
	if current_minute > _last_minute:
		_last_minute = current_minute
		elapsed_minutes = current_minute
		minute_passed.emit(current_minute)

func start_clock() -> void:
	elapsed_time = 0.0
	elapsed_minutes = 0
	_last_second = 0
	_last_minute = 0
	is_running = true
	set_process(true)
	game_started.emit()

func pause_clock() -> void:
	is_running = false
	set_process(false)
	game_paused.emit()

func resume_clock() -> void:
	is_running = true
	set_process(true)
	game_resumed.emit()

func stop_clock() -> void:
	is_running = false
	set_process(false)

func reset_clock() -> void:
	elapsed_time = 0.0
	elapsed_minutes = 0
	_last_second = 0
	_last_minute = 0
	is_running = false
	set_process(false)

## Get the time progress as a normalized value (0.0 to 1.0) based on max game time
func get_time_progress(max_time_minutes: float = 30.0) -> float:
	return clampf(elapsed_time / (max_time_minutes * 60.0), 0.0, 1.0)

## Get formatted time string (MM:SS)
func get_formatted_time() -> String:
	var minutes = int(elapsed_time) / 60.0
	var seconds = int(elapsed_time) % 60
	return "%02d:%02d" % [minutes, seconds]
