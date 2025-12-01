extends Node

## Session statistics
var session_enemies_defeated: int = 0
var session_bosses_defeated: int = 0
var session_chests_opened: int = 0
var session_weapons_acquired: int = 0
var session_weapons_upgraded: int = 0
var session_health_pickups: int = 0
var session_total_exp: int = 0


func _ready() -> void:
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)
	SignalManager.chest_collected.connect(_on_chest_collected)
	SignalManager.exp_gained.connect(_on_exp_gained)
	SignalManager.health_pickup_collected.connect(_on_health_pickup_collected)
	SignalManager.weapon_acquired.connect(_on_weapon_acquired)
	SignalManager.weapon_upgraded.connect(_on_weapon_upgraded)
	GameClock.game_started.connect(_on_game_started)


func _on_enemy_defeated(is_boss: bool) -> void:
	session_enemies_defeated += 1
	if is_boss:
		session_bosses_defeated += 1


func _on_chest_collected() -> void:
	session_chests_opened += 1


func _on_exp_gained(amount: int) -> void:
	session_total_exp += amount


func _on_health_pickup_collected(_amount: int) -> void:
	session_health_pickups += 1


func _on_weapon_acquired() -> void:
	session_weapons_acquired += 1


func _on_weapon_upgraded() -> void:
	session_weapons_upgraded += 1


func _on_game_started() -> void:
	reset_session()


func reset_session() -> void:
	session_enemies_defeated = 0
	session_bosses_defeated = 0
	session_chests_opened = 0
	session_weapons_acquired = 0
	session_weapons_upgraded = 0
	session_health_pickups = 0
	session_total_exp = 0
