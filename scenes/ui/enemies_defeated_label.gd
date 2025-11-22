extends Control

@onready var enemies_defeated_label: Label = %Label

func _ready() -> void:
	_update_label()
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)

func _update_label() -> void:
	enemies_defeated_label.text = "Enemies Defeated: %d" % GameManager.session_enemies_defeated

func _on_enemy_defeated() -> void:
	_update_label()
