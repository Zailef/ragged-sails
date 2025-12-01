extends VBoxContainer
class_name WeaponBar

## Displays unlocked weapons with their icons and levels on the right side of the screen.

const WEAPON_SLOT = preload("res://scenes/ui/weapon_slot.tscn")

var all_weapons: Dictionary = {} # weapon_id -> WeaponData
var _weapon_slots: Dictionary = {} # weapon_id -> WeaponSlot node
var _weapon_manager: WeaponManager = null

func _ready() -> void:
	_load_all_weapons()
	# Connect to WeaponManager signals when available
	_connect_to_weapon_manager.call_deferred()

func _load_all_weapons() -> void:
	for weapon_id in WeaponConstants.WEAPON_DATA_PATHS:
		var path = WeaponConstants.WEAPON_DATA_PATHS[weapon_id]
		var weapon = load(path)
		if weapon:
			all_weapons[weapon_id] = weapon
		else:
			push_error("WeaponBar: Failed to load weapon from " + path)

func _connect_to_weapon_manager() -> void:
	var weapon_mgr = _get_weapon_manager()
	if weapon_mgr:
		weapon_mgr.weapon_unlocked.connect(_on_weapon_unlocked)
		weapon_mgr.weapon_upgraded.connect(_on_weapon_upgraded)
		# Add any already unlocked weapons
		for weapon_id in weapon_mgr.get_unlocked_weapons():
			_add_weapon_slot(weapon_id)

func _get_weapon_manager() -> WeaponManager:
	if not _weapon_manager:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			_weapon_manager = player.weapon_manager
	return _weapon_manager

func _on_weapon_unlocked(weapon_id: String) -> void:
	_add_weapon_slot(weapon_id)

func _on_weapon_upgraded(weapon_id: String, new_level: int) -> void:
	if weapon_id in _weapon_slots:
		_weapon_slots[weapon_id].set_level(new_level)

func _add_weapon_slot(weapon_id: String) -> void:
	if weapon_id in _weapon_slots:
		return # Already exists
	
	if weapon_id not in all_weapons:
		return # Unknown weapon
	
	var weapon_data = all_weapons[weapon_id]
	var slot = WEAPON_SLOT.instantiate()
	add_child(slot)
	
	# Get current level from weapon's level_manager
	var current_level = 1
	var weapon_mgr = _get_weapon_manager()
	if weapon_mgr:
		var weapon = weapon_mgr.get_weapon(weapon_id)
		if weapon and weapon.level_manager:
			current_level = weapon.level_manager.current_level
	
	slot.setup(weapon_data, current_level)
	_weapon_slots[weapon_id] = slot
