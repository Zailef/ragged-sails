extends Node2D

const DeathScreenScene = preload("res://scenes/menus/death_screen.tscn")

var death_screen: DeathScreen


func _ready() -> void:
	GameClock.start_clock()
	SignalManager.player_died.connect(_on_player_died)
	
	# Pre-instantiate death screen so it's ready when needed
	death_screen = DeathScreenScene.instantiate()
	add_child(death_screen)


func _on_player_died() -> void:
	death_screen.show_death_screen()
