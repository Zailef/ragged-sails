extends Weapon
class_name Mine

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_cast: ShapeCast2D = $ExplosionCast

@export var detonate_animation_offset = Vector2(0, -28)
@export var arm_delay: float = 1.0
@export var lifetime: float = 10.0
@export var damage_delay: float = 0.15

var is_armed: bool = false
var is_detonating: bool = false
var arm_timer: float = 0.0
var lifetime_timer: float = 0.0
var damaged_enemies: Array[Enemy] = []

func _ready() -> void:
	super ()
	sprite.play("default")
	explosion_cast.enabled = false
	hide()

func _physics_process(delta: float) -> void:
	if current_state != WeaponState.ACTIVE:
		return

	if is_detonating:
		return # Wait for animation to finish

	if not is_armed:
		arm_timer += delta
		if arm_timer >= arm_delay:
			is_armed = true
			explosion_cast.enabled = true
	else:
		# Check for enemies in range
		explosion_cast.force_shapecast_update()
		if explosion_cast.get_collision_count() > 0:
			_detonate()
			return

		lifetime_timer += delta
		if lifetime_timer >= lifetime:
			end_active_phase()

func _fire_weapon() -> void:
	# Mine is placed at player's position
	global_position = get_owner().global_position

func _activate() -> void:
	is_armed = false
	is_detonating = false
	arm_timer = 0.0
	lifetime_timer = 0.0
	damaged_enemies.clear()
	sprite.play("default")
	sprite.offset = Vector2.ZERO
	show()

func _reset_weapon() -> void:
	is_armed = false
	is_detonating = false
	arm_timer = 0.0
	lifetime_timer = 0.0
	damaged_enemies.clear()
	explosion_cast.enabled = false
	hide()

func _detonate() -> void:
	if is_detonating:
		return

	is_detonating = true
	explosion_cast.enabled = false

	# Apply offset for explosion animation
	if sprite:
		sprite.offset = detonate_animation_offset
		sprite.play("detonate")

	# Delay damage application to sync with explosion visual
	await get_tree().create_timer(damage_delay).timeout

	explosion_cast.enabled = true
	explosion_cast.force_shapecast_update()
	explosion_cast.enabled = false

	var collision_count = explosion_cast.get_collision_count()

	for i in range(collision_count):
		var collider = explosion_cast.get_collider(i)
		if collider.get_owner() is Enemy:
			var enemy: Enemy = collider.get_owner()
			if enemy not in damaged_enemies:
				enemy.take_damage(weapon_stats.damage)
				damaged_enemies.append(enemy)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "detonate":
		end_active_phase()
