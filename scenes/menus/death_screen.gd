extends CanvasLayer
class_name DeathScreen

signal replay_pressed
signal credits_pressed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stats_label: Label = $Control/PanelContainer/VBoxContainer/StatsLabel


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_death_screen() -> void:
	_update_stats()
	show()
	animation_player.play("fade_in")
	get_tree().paused = true


func _update_stats() -> void:
	var elapsed = GameClock.elapsed_time
	@warning_ignore("integer_division")
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	stats_label.text = "You survived for %d:%02d" % [minutes, seconds]


func _on_replay_button_pressed() -> void:
	get_tree().paused = false
	replay_pressed.emit()
	get_tree().reload_current_scene()


func _on_credits_button_pressed() -> void:
	get_tree().paused = false
	credits_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/menus/credits_menu.tscn")
