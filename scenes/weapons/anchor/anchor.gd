extends BaseWeapon
class_name Anchor

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea

@export var orbit_radius: float = 48.0
var orbit_angle: float = 0.0

func _process(delta: float) -> void:
	if not is_visible():
		return

	orbit_angle += weapon_stats.speed * delta
	var player_pos = get_player().global_position
	global_position = player_pos + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	rotation = orbit_angle

func _fire_weapon() -> void:
	_activate()

func _reset_weapon() -> void:
	damage_area.monitoring = false
	orbit_angle = 0.0
	global_position = get_player().global_position
	hide()

func _activate() -> void:
	damage_area.monitoring = true
	show()
