extends Weapon

@onready var rope: Line2D = $Line2D

@export var damage_rate: float = 0.5
@export var flight_speed: float = 300.0

var is_pinned: bool = false
var is_flying: bool = false
var target: Enemy = null
var target_marker: Marker2D = null
var damage_timer: float = 0.0

func _ready() -> void:
	super ()
	rope.visible = false
	hide()

func _physics_process(_delta: float) -> void:
	if current_state != WeaponState.ACTIVE:
		return

	if is_flying and target and is_instance_valid(target) and target_marker and is_instance_valid(target_marker):
		# Fly towards target marker
		var marker_pos = target_marker.global_position
		var to_target = (marker_pos - global_position).normalized()
		global_position += to_target * flight_speed * _delta
		rotation = to_target.angle()

		rope.visible = true
		_update_rope()

		# Check if we've reached the target
		if global_position.distance_to(marker_pos) < 10.0:
			is_flying = false
			is_pinned = true
			damage_timer = 0.0
	elif is_pinned and target and is_instance_valid(target) and target_marker and is_instance_valid(target_marker):
		# Stick to the target marker's position
		global_position = target_marker.global_position

		# Update rotation to point from ship to harpoon
		var to_harpoon: Vector2 = (global_position - get_player().global_position).normalized()
		rotation = to_harpoon.angle()

		_update_rope()
		_apply_damage(_delta)
	elif is_pinned or is_flying:
		# Target died or became invalid, release harpoon
		end_active_phase()

func _fire_weapon() -> void:
	global_position = get_player().global_position

	var context: TargetingContext = TargetingContext.new()
	context.user = get_player()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_target():
		target = result.target
		target_marker = target.get_node_or_null("AnimatedSprite2D/TargetMarker")
		if not target_marker:
			# Fallback to target center if no marker
			is_flying = false
			is_pinned = false
			return
		
		var to_target: Vector2 = (target_marker.global_position - global_position).normalized()
		rotation = to_target.angle()
		is_flying = true
		is_pinned = false
	else:
		# No target found, don't activate
		is_flying = false
		is_pinned = false

func _activate() -> void:
	if not is_flying:
		end_active_phase()
		return

	damage_timer = 0.0
	rope.visible = false
	show()

func _reset_weapon() -> void:
	is_pinned = false
	is_flying = false
	target = null
	target_marker = null
	damage_timer = 0.0
	rope.visible = false
	hide()

func _apply_damage(delta: float) -> void:
	damage_timer += delta
	if damage_timer >= damage_rate:
		target.take_damage(weapon_stats.damage)
		damage_timer = 0.0

func _update_rope() -> void:
	var ship_pos = get_player().global_position
	var start = to_local(ship_pos)
	var end = Vector2.ZERO
	rope.points = [start, end]
