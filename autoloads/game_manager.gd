extends Node

var session_enemies_defeated: int = 0

func _ready() -> void:
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)
	GameClock.game_started.connect(_on_game_started)

func _on_enemy_defeated() -> void:
	session_enemies_defeated += 1

func _on_game_started() -> void:
	reset_session()

func reset_session() -> void:
	session_enemies_defeated = 0
