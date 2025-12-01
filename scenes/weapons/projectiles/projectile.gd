## Base class for all weapon projectiles.
## Projectiles are spawned by weapons and handle their own movement, collision, and cleanup.
extends Node2D
class_name Projectile

## Emitted when the projectile hits an enemy
signal hit_enemy(enemy: Enemy)

## Emitted when the projectile is destroyed (for any reason)
signal destroyed

## The damage this projectile deals
var damage: int = 10

## Movement direction (normalized)
var direction: Vector2 = Vector2.ZERO

## Movement speed in pixels per second
var speed: float = 200.0

## Maximum travel distance before self-destruct (-1 for infinite)
var max_distance: float = -1.0

## Reference to the weapon that spawned this projectile (for upgrade callbacks)
var source_weapon: BaseWeapon = null

## Track distance traveled
var _distance_traveled: float = 0.0

## Track enemies already hit (for penetration limit)
var _enemies_hit: Array[Enemy] = []

## Number of enemies this projectile can penetrate (-1 for infinite)
var penetration: int = 1


func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	
	_move(delta)
	_check_max_distance()


## Override in subclasses for custom movement
func _move(delta: float) -> void:
	var movement = direction * speed * delta
	global_position += movement
	_distance_traveled += movement.length()


## Check if projectile has exceeded max distance
func _check_max_distance() -> void:
	if max_distance > 0 and _distance_traveled >= max_distance:
		_on_max_distance_reached()


## Called when max distance is reached. Override for custom behavior.
func _on_max_distance_reached() -> void:
	destroy()


## Called when the projectile collides with an enemy
func _on_enemy_hit(enemy: Enemy) -> void:
	if not is_instance_valid(enemy):
		return
	
	if enemy in _enemies_hit:
		return
	
	_enemies_hit.append(enemy)
	enemy.take_damage(damage)
	hit_enemy.emit(enemy)
	
	# Notify source weapon for upgrade hooks
	if source_weapon and is_instance_valid(source_weapon):
		source_weapon.notify_enemy_hit(enemy)
	
	# Check penetration (destroy if we've hit enough enemies)
	# penetration = 1 means destroy after first hit
	# penetration = -1 means never destroy from hits
	if penetration >= 0 and _enemies_hit.size() >= penetration:
		destroy()


## Initialize the projectile with common parameters
func setup(p_direction: Vector2, p_damage: int, p_speed: float, p_max_distance: float = -1.0, p_source: BaseWeapon = null, p_penetration: int = 1) -> void:
	direction = p_direction.normalized()
	damage = p_damage
	speed = p_speed
	max_distance = p_max_distance
	source_weapon = p_source
	penetration = p_penetration
	
	# Rotate sprite to face direction
	rotation = direction.angle()


## Destroy the projectile and clean up
func destroy() -> void:
	destroyed.emit()
	queue_free()
