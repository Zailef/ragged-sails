extends Control
class_name LevelUp

## Displays weapon choices when the player levels up.

@export var num_choices: int = 3

@onready var container: HBoxContainer = $MarginContainer/HBoxContainer

var all_weapons: Dictionary = {} # weapon_id -> WeaponData
var _weapon_manager: WeaponManager = null
var _pending_levels: int = 0

func _ready() -> void:
	SignalManager.player_levelled_up.connect(_on_player_levelled_up)
	hide()
	_load_all_weapons()

func _load_all_weapons() -> void:
	for weapon_id in WeaponConstants.WEAPON_DATA_PATHS:
		var path = WeaponConstants.WEAPON_DATA_PATHS[weapon_id]
		var weapon = load(path)
		if weapon:
			all_weapons[weapon_id] = weapon
		else:
			push_error("LevelUp: Failed to load weapon from " + path)

func _get_weapon_manager() -> WeaponManager:
	if not _weapon_manager:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			_weapon_manager = player.weapon_manager
	return _weapon_manager

func _on_player_levelled_up(_new_level: int, _exp_to_next: int) -> void:
	_pending_levels += 1
	if not visible:
		_show_level_up()

func _show_level_up() -> void:
	if _pending_levels <= 0:
		return
	
	_pending_levels -= 1
	
	var weapon_mgr = _get_weapon_manager()
	if not weapon_mgr:
		push_error("LevelUp: Could not find WeaponManager")
		return
	
	# Get locked weapons from WeaponManager
	var locked_ids = weapon_mgr.get_locked_weapons()
	var available: Array[Resource] = []
	for weapon_id in locked_ids:
		if weapon_id in all_weapons:
			available.append(all_weapons[weapon_id])
	
	
	if available.is_empty():
		# All weapons unlocked, just continue
		SignalManager.level_up_selection_made.emit()
		if _pending_levels > 0:
			_show_level_up()
		return
	
	# Pause the game
	get_tree().paused = true
	
	# Pick random weapons
	var choices = _pick_random_choices(available, min(num_choices, available.size()))
	
	# Setup the item frames with weapon data
	var items = container.get_children()
	for i in items.size():
		var item = items[i]
		if i < choices.size():
			item.setup(choices[i])
			item.show()
			# Connect signal if not already connected
			if not item.selected.is_connected(_on_weapon_selected):
				item.selected.connect(_on_weapon_selected)
		else:
			item.hide()
	
	show()

func _pick_random_choices(available: Array[Resource], count: int) -> Array[Resource]:
	var choices: Array[Resource] = []
	var pool = available.duplicate()
	
	for i in count:
		if pool.is_empty():
			break
		var index = randi() % pool.size()
		choices.append(pool[index])
		pool.remove_at(index)
	
	return choices

func _on_weapon_selected(weapon_data: Resource) -> void:
	var weapon_mgr = _get_weapon_manager()
	if weapon_mgr:
		weapon_mgr.unlock_weapon(weapon_data.id)
	
	hide()
	get_tree().paused = false
	SignalManager.level_up_selection_made.emit()
	
	# Check for more pending level ups
	if _pending_levels > 0:
		call_deferred("_show_level_up")
