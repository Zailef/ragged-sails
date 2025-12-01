## Dual Harpoons - Fires a second harpoon at a different target.
extends WeaponUpgrade
class_name DualHarpoonsUpgrade

const SecondaryHarpoonScript = preload("res://scenes/weapons/harpoon/upgrades/secondary_harpoon.gd")

## Delay before firing the second harpoon
@export var second_harpoon_delay: float = 0.2

var _pending_fire: bool = false
var _fire_timer: float = 0.0
var _weapon_ref: WeakRef = null
var _excluded_target: Enemy = null


func _init() -> void:
	id = &"dual_harpoons"
	display_name = "Dual Harpoons"
	description = "Fire a second harpoon at a different enemy."


func on_fire(weapon: BaseWeapon) -> void:
	var harpoon := weapon as Harpoon
	if not harpoon:
		return

	# Store reference to fire second harpoon after delay
	_weapon_ref = weakref(weapon)
	_excluded_target = harpoon.target
	_pending_fire = true
	_fire_timer = 0.0


func on_physics_process(weapon: BaseWeapon, delta: float) -> void:
	if not _pending_fire:
		return

	_fire_timer += delta
	if _fire_timer >= second_harpoon_delay:
		_pending_fire = false
		_fire_second_harpoon(weapon)


func on_reset(_weapon: BaseWeapon) -> void:
	_pending_fire = false
	_fire_timer = 0.0
	_excluded_target = null


func _fire_second_harpoon(weapon: BaseWeapon) -> void:
	var harpoon := weapon as Harpoon
	if not harpoon:
		return

	# Find a different target
	var context := TargetingContext.new()
	context.user = harpoon.get_player()
	context.enemies = _get_valid_enemies(weapon)
	context.weapon_stats = harpoon.weapon_stats

	if context.enemies.is_empty():
		return

	var result: TargetingResult = harpoon.targeting_strategy.get_target(context)

	if result.has_target():
		_spawn_secondary_harpoon(harpoon, result.target)


func _get_valid_enemies(weapon: BaseWeapon) -> Array[Node]:
	var all_enemies = weapon.get_tree().get_nodes_in_group("enemies")
	var valid: Array[Node] = []

	for enemy in all_enemies:
		if enemy == _excluded_target:
			continue
		if enemy is Enemy and is_instance_valid(enemy):
			valid.append(enemy)

	return valid


func _spawn_secondary_harpoon(primary: Harpoon, new_target: Enemy) -> void:
	# Create a secondary harpoon projectile
	var secondary: Node2D = SecondaryHarpoonScript.new()
	secondary.setup(primary, new_target)
	primary.get_tree().current_scene.add_child(secondary)
