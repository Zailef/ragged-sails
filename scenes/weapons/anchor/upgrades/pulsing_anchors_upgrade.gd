## Pulsing Anchors - Anchors move outward and inward while orbiting.
extends WeaponUpgrade
class_name PulsingAnchorsUpgrade

@export var pulse_speed: float = 3.0
@export var pulse_amount: float = 20.0  # How far they move in/out

var pulse_time: float = 0.0


func on_physics_process(weapon: BaseWeapon, delta: float) -> void:
	var anchor_weapon = weapon as Anchor
	if not anchor_weapon:
		return
	
	pulse_time += delta * pulse_speed
	var pulse_offset = sin(pulse_time) * pulse_amount
	
	for anchor in anchor_weapon.anchors:
		if is_instance_valid(anchor):
			anchor.orbit_radius = anchor_weapon.orbit_radius + pulse_offset


func on_reset(_weapon: BaseWeapon) -> void:
	pulse_time = 0.0
