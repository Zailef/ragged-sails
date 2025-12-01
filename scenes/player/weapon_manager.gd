extends Node
class_name WeaponManager

## Manages all weapons for the player. Weapons are pre-loaded as children
## but disabled until unlocked.

signal weapon_unlocked(weapon_id: String)
signal weapon_upgraded(weapon_id: String, new_level: int)

# Dictionary mapping weapon_id -> weapon node
var _weapons: Dictionary = {}
var _unlocked_weapons: Array[String] = []

func _ready() -> void:
	# Register all child weapons
	for child in get_children():
		if child is BaseWeapon:
			var weapon_id = child.name.to_lower()
			_weapons[weapon_id] = child
			# Start all weapons disabled and hidden
			child.set_process(false)
			child.set_physics_process(false)
			child.hide()


func unlock_weapon(weapon_id: String) -> bool:
	weapon_id = weapon_id.to_lower()
	
	if weapon_id not in _weapons:
		push_error("WeaponManager: Unknown weapon: " + weapon_id)
		return false
	
	if weapon_id in _unlocked_weapons:
		# Already unlocked - this is an upgrade
		return upgrade_weapon(weapon_id)
	
	var weapon = _weapons[weapon_id]
	_unlocked_weapons.append(weapon_id)
	
	# Enable the weapon
	weapon.set_process(true)
	weapon.set_physics_process(true)
	weapon.show()
	weapon.call_deferred("_start_weapon_cycle")
	
	weapon_unlocked.emit(weapon_id)
	return true

func upgrade_weapon(weapon_id: String) -> bool:
	weapon_id = weapon_id.to_lower()
	
	if weapon_id not in _weapons:
		push_error("WeaponManager: Unknown weapon: " + weapon_id)
		return false
	
	if weapon_id not in _unlocked_weapons:
		push_error("WeaponManager: Cannot upgrade locked weapon: " + weapon_id)
		return false
	
	var weapon = _weapons[weapon_id]
	if weapon.level_manager:
		var success = weapon.level_manager.level_up()
		if success:
			weapon_upgraded.emit(weapon_id, weapon.level_manager.current_level)
			return true
		return false
	
	# Fallback for weapons without level manager
	weapon_upgraded.emit(weapon_id, 1)
	return true

func is_unlocked(weapon_id: String) -> bool:
	return weapon_id.to_lower() in _unlocked_weapons

func get_unlocked_weapons() -> Array[String]:
	return _unlocked_weapons.duplicate()

func get_locked_weapons() -> Array[String]:
	var locked: Array[String] = []
	for weapon_id in _weapons.keys():
		if weapon_id not in _unlocked_weapons:
			locked.append(weapon_id)
	return locked

func get_all_weapon_ids() -> Array:
	return _weapons.keys()

func get_weapon(weapon_id: String) -> BaseWeapon:
	return _weapons.get(weapon_id.to_lower())
