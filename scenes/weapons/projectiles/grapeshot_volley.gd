## A grapeshot volley that damages enemies in a cone area.
extends Projectile
class_name GrapeshotVolley

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var fire_sound: AudioStreamPlayer = $FireSound

var _damaged_enemies: Array[Enemy] = []


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	shape_cast.enabled = true
	animated_sprite.play("default")
	fire_sound.play()


func _physics_process(_delta: float) -> void:
	# Grapeshot doesn't move, it just does damage in an area
	if not shape_cast.enabled:
		return
	
	shape_cast.force_shapecast_update()
	for i in range(shape_cast.get_collision_count()):
		var collider = shape_cast.get_collider(i)
		if collider.get_owner() is Enemy:
			var enemy: Enemy = collider.get_owner()
			if enemy not in _damaged_enemies:
				enemy.take_damage(damage)
				_damaged_enemies.append(enemy)
				
				# Notify source weapon for upgrade hooks
				if source_weapon and is_instance_valid(source_weapon):
					source_weapon.notify_enemy_hit(enemy)


func setup(p_direction: Vector2, p_damage: int, _p_speed: float = 0.0, _p_max_distance: float = -1.0, p_source: BaseWeapon = null) -> void:
	direction = p_direction.normalized()
	damage = p_damage
	source_weapon = p_source
	
	# Rotate to face direction
	rotation = direction.angle()


func _on_animation_finished() -> void:
	shape_cast.enabled = false
	destroy()
