extends Control
class_name LevelUp

## Displays weapon choices when the player levels up.
## Can show new weapon unlocks or upgrades for existing weapons.

@export var num_choices: int = 3
## Chance (0-1) that a slot will show an upgrade instead of a new weapon (if available)
@export var upgrade_chance: float = 0.4

@onready var container: HBoxContainer = $MarginContainer/HBoxContainer

var all_weapons: Dictionary = {} # weapon_id -> WeaponData
var _weapon_manager: WeaponManager = null
var _pending_levels: int = 0

## Represents a choice option (either unlock or upgrade)
class LevelUpChoice:
	var weapon_data: Resource
	var is_upgrade: bool
	var current_level: int

	func _init(data: Resource, upgrade: bool = false, level: int = 0) -> void:
		weapon_data = data
		is_upgrade = upgrade
		current_level = level


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

	# Build pools of available options
	var unlock_pool: Array[LevelUpChoice] = []
	var upgrade_pool: Array[LevelUpChoice] = []

	# Get locked weapons for unlock pool
	var locked_ids = weapon_mgr.get_locked_weapons()
	for weapon_id in locked_ids:
		if weapon_id in all_weapons:
			unlock_pool.append(LevelUpChoice.new(all_weapons[weapon_id], false, 0))

	# Get unlocked weapons for upgrade pool
	var unlocked_ids = weapon_mgr.get_unlocked_weapons()
	for weapon_id in unlocked_ids:
		if weapon_id in all_weapons:
			var weapon = weapon_mgr.get_weapon(weapon_id)
			if weapon and weapon.level_manager:
				var current_lvl = weapon.level_manager.current_level
				# Check if weapon can be upgraded
				if weapon.level_manager.level_up():
					# Undo the level up - we just wanted to check if it's possible
					weapon.level_manager.current_level = current_lvl
					upgrade_pool.append(LevelUpChoice.new(all_weapons[weapon_id], true, current_lvl))

	# Check if we have any options at all
	if unlock_pool.is_empty() and upgrade_pool.is_empty():
		SignalManager.level_up_selection_made.emit()
		if _pending_levels > 0:
			_show_level_up()
		return

	# Pause the game
	get_tree().paused = true

	# Pick choices mixing unlocks and upgrades
	var choices = _pick_mixed_choices(unlock_pool, upgrade_pool, num_choices)

	# Setup the item frames with weapon data
	var items = container.get_children()
	for i in items.size():
		var item = items[i]
		if i < choices.size():
			var choice = choices[i]
			if choice.is_upgrade:
				item.setup_upgrade(choice.weapon_data, choice.current_level)
			else:
				item.setup(choice.weapon_data)
			item.show()
			# Connect signal if not already connected
			if not item.selected.is_connected(_on_weapon_selected):
				item.selected.connect(_on_weapon_selected)
		else:
			item.hide()

	show()


func _pick_mixed_choices(unlock_pool: Array[LevelUpChoice], upgrade_pool: Array[LevelUpChoice], count: int) -> Array[LevelUpChoice]:
	var choices: Array[LevelUpChoice] = []
	var unlocks = unlock_pool.duplicate()
	var upgrades = upgrade_pool.duplicate()

	for i in count:
		if unlocks.is_empty() and upgrades.is_empty():
			break

		var pick_upgrade = false

		# Decide whether to pick an upgrade or unlock
		if unlocks.is_empty():
			pick_upgrade = true
		elif upgrades.is_empty():
			pick_upgrade = false
		else:
			# Random chance to pick upgrade
			pick_upgrade = randf() < upgrade_chance

		if pick_upgrade and not upgrades.is_empty():
			var index = randi() % upgrades.size()
			choices.append(upgrades[index])
			upgrades.remove_at(index)
		elif not unlocks.is_empty():
			var index = randi() % unlocks.size()
			choices.append(unlocks[index])
			unlocks.remove_at(index)

	return choices


func _on_weapon_selected(weapon_data: Resource, is_upgrade: bool) -> void:
	var weapon_mgr = _get_weapon_manager()
	if weapon_mgr:
		if is_upgrade:
			weapon_mgr.upgrade_weapon(weapon_data.id)
			SignalManager.weapon_upgraded.emit()
		else:
			weapon_mgr.unlock_weapon(weapon_data.id)
			SignalManager.weapon_acquired.emit()

	hide()
	get_tree().paused = false
	SignalManager.level_up_selection_made.emit()
	SignalManager.menu_closed.emit()

	# Check for more pending level ups
	if _pending_levels > 0:
		call_deferred("_show_level_up")
