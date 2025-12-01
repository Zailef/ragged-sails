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
	
	var lines: Array[String] = []
	lines.append("You survived for %d:%02d" % [minutes, seconds])
	lines.append("")
	
	# Enemies
	var enemies = GameManager.session_enemies_defeated
	var bosses = GameManager.session_bosses_defeated
	if bosses > 0:
		lines.append("Enemies defeated: %d (%d bosses)" % [enemies, bosses])
	else:
		lines.append("Enemies defeated: %d" % enemies)
	
	# Chests
	var chests = GameManager.session_chests_opened
	if chests > 0:
		lines.append("Chests opened: %d" % chests)
	
	# Weapons
	var acquired = GameManager.session_weapons_acquired
	var upgraded = GameManager.session_weapons_upgraded
	if acquired > 0:
		lines.append("Weapons acquired: %d" % acquired)
	if upgraded > 0:
		lines.append("Weapon upgrades: %d" % upgraded)
	
	# Health pickups
	var health = GameManager.session_health_pickups
	if health > 0:
		lines.append("Health pickups: %d" % health)
	
	# Total EXP
	var total_exp = GameManager.session_total_exp
	lines.append("Total EXP: %d" % total_exp)
	
	stats_label.text = "\n".join(lines)


func _on_replay_button_pressed() -> void:
	get_tree().paused = false
	replay_pressed.emit()
	get_tree().reload_current_scene()


func _on_credits_button_pressed() -> void:
	get_tree().paused = false
	credits_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/menus/credits_menu.tscn")
