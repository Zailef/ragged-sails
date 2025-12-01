## A mine projectile that arms after a delay and explodes when enemies are near.
extends Projectile
class_name MineProjectile

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_cast: ShapeCast2D = $ExplosionCast
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound

@export var detonate_animation_offset: Vector2 = Vector2(0, -28)
@export var arm_delay: float = 1.0
@export var lifetime: float = 10.0
@export var damage_delay: float = 0.15

var is_armed: bool = false
var is_detonating: bool = false
var arm_timer: float = 0.0
var lifetime_timer: float = 0.0


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("default")
	explosion_cast.enabled = false


func _physics_process(delta: float) -> void:
	if is_detonating:
		return
	
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
			destroy()


func setup(p_direction: Vector2, p_damage: int, _p_speed: float = 0.0, _p_max_distance: float = -1.0, p_source: BaseWeapon = null, _p_penetration: int = -1) -> void:
	direction = p_direction
	damage = p_damage
	source_weapon = p_source


func _detonate() -> void:
	if is_detonating:
		return
	
	is_detonating = true
	explosion_cast.enabled = false
	
	# Apply offset for explosion animation
	sprite.offset = detonate_animation_offset
	sprite.play("detonate")
	explosion_sound.play()
	
	# Delay damage application to sync with explosion visual
	await get_tree().create_timer(damage_delay).timeout
	
	if not is_instance_valid(self):
		return
	
	explosion_cast.enabled = true
	explosion_cast.force_shapecast_update()
	explosion_cast.enabled = false
	
	for i in range(explosion_cast.get_collision_count()):
		var collider = explosion_cast.get_collider(i)
		if collider.get_owner() is Enemy:
			var enemy: Enemy = collider.get_owner()
			enemy.take_damage(damage)
			
			if source_weapon and is_instance_valid(source_weapon):
				source_weapon.notify_enemy_hit(enemy)


func _on_animation_finished() -> void:
	if sprite.animation == "detonate":
		destroy()
