extends Control

@onready var exp_bar: TextureProgressBar = %ExpBar
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
	SignalManager.exp_gained.connect(_on_exp_gained)
	SignalManager.player_levelled_up.connect(_on_level_up)
	SignalManager.max_level_reached.connect(_on_max_level_reached)

	exp_bar.value = 0
	exp_bar.max_value = 5 # base_exp(5) for level 2
	level_label.text = "Level 1"

func _on_exp_gained(amount: int) -> void:
	exp_bar.value += amount

func _on_level_up(new_level: int, exp_to_next: int) -> void:
	exp_bar.max_value = exp_to_next
	exp_bar.value = 0
	level_label.text = "Level %d" % new_level

func _on_max_level_reached() -> void:
	exp_bar.value = exp_bar.max_value
	level_label.text = "MAX LEVEL"
