extends Control

@onready var exp_bar: ProgressBar = %ExpBar
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
	SignalManager.exp_gained.connect(_on_exp_gained)
	SignalManager.player_levelled_up.connect(_on_level_up)
	exp_bar.value = 0
	exp_bar.max_value = 5 # TODO: set initial max value appropriately

func _on_exp_gained(amount: int) -> void:
	exp_bar.value += amount

func _on_level_up(new_level: int, exp_to_next: int) -> void:
	exp_bar.max_value = exp_to_next
	exp_bar.value = 0
	level_label.text = "Level %d" % new_level
