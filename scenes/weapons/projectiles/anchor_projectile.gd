## An anchor that orbits around the player dealing damage to enemies it hits.
extends Projectile
class_name AnchorProjectile

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea

var orbit_radius: float = 48.0
var orbit_speed: float = 2.0
var orbit_angle: float = 0.0
var player: Node2D = null


func _ready() -> void:
	damage_area.area_entered.connect(_on_damage_area_entered)


func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return
	
	orbit_angle += orbit_speed * delta
	global_position = player.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	rotation = orbit_angle


func setup_anchor(p_player: Node2D, p_damage: int, p_orbit_radius: float, p_orbit_speed: float, p_start_angle: float, p_source: BaseWeapon) -> void:
	player = p_player
	damage = p_damage
	orbit_radius = p_orbit_radius
	orbit_speed = p_orbit_speed
	orbit_angle = p_start_angle
	source_weapon = p_source
	
	# Initialize position immediately
	if player:
		global_position = player.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		rotation = orbit_angle


func activate() -> void:
	damage_area.monitoring = true
	show()


func deactivate() -> void:
	damage_area.monitoring = false
	hide()


func _on_damage_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is Enemy and is_instance_valid(enemy):
		enemy.take_damage(damage)
		if source_weapon and is_instance_valid(source_weapon):
			source_weapon.notify_enemy_hit(enemy)
