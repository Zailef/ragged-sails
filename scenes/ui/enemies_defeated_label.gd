extends Control

@onready var enemies_defeated_label: Label = %Label

func _ready() -> void:
	_update_label()
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)
	GameClock.game_started.connect(_on_game_started)

func _update_label() -> void:
	enemies_defeated_label.text = "Enemies Defeated: %d" % GameManager.session_enemies_defeated

func _on_enemy_defeated(_is_boss: bool) -> void:
	_update_label()

func _on_game_started() -> void:
	_update_label()
