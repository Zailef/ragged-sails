@abstract
extends Node2D
class_name BaseWeapon

@export var weapon_stats: WeaponStats
@export var targeting_strategy: TargetingStrategy

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var duration_timer: Timer = $DurationTimer

enum WeaponState {READY, ACTIVE, COOLDOWN}
var current_state: WeaponState = WeaponState.READY

## Gets the player node. Since weapons are children of WeaponManager,
## navigate up to find the player in the "player" group.
func get_player() -> Node2D:
	# First try get_owner() which works if scene is properly set up
	var owner_node = get_owner()
	if owner_node and owner_node is Player:
		return owner_node
	# Otherwise find through WeaponManager's parent
	var parent = get_parent()
	if parent and parent.get_parent() and parent.get_parent() is Player:
		return parent.get_parent()
	# Last resort: search the tree
	return get_tree().get_first_node_in_group("player")

func _ready() -> void:
	_initialise_timers()
	_reset_weapon()
	# Don't auto-start - WeaponManager will call _start_weapon_cycle when unlocked

func _initialise_timers() -> void:
	cooldown_timer.wait_time = weapon_stats.cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	if weapon_stats.duration > 0.0:
		duration_timer.wait_time = weapon_stats.duration
		duration_timer.one_shot = true
		duration_timer.timeout.connect(_on_duration_timeout)

func _start_weapon_cycle() -> void:
	if current_state == WeaponState.READY:
		_fire_and_activate()

func _fire_and_activate() -> void:
	current_state = WeaponState.ACTIVE
	_fire_weapon()
	_activate()

	# Only start duration timer if duration is positive
	# Duration of 0 or less means infinite/manual duration control
	if weapon_stats.duration > 0.0:
		duration_timer.start()

func _on_duration_timeout() -> void:
	_reset_weapon()
	current_state = WeaponState.COOLDOWN
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	current_state = WeaponState.READY
	_start_weapon_cycle()

# Call this from concrete weapons to manually end the active phase
# Useful for weapons with duration <= 0 (infinite duration)
func end_active_phase() -> void:
	if current_state == WeaponState.ACTIVE:
		_on_duration_timeout()

@abstract
func _fire_weapon() -> void

@abstract
func _reset_weapon() -> void

@abstract
func _activate() -> void
