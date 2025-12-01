## A trident projectile that drops from above and creates a whirlpool on impact.
extends Projectile
class_name TridentProjectile

const SPRITE_SIZE: int = 32

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var whirlpool_sprite: AnimatedSprite2D = $WhirlpoolSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var drop_speed: float = 200.0
@export var slow_effect: SlowEffect
@export var whirlpool_duration: float = 5.0

var target_position: Vector2 = Vector2.ZERO
var target_enemy: Enemy = null
var is_dropping: bool = true
var affected_enemies: Array[Enemy] = []
var whirlpool_timer: float = 0.0

## Bonus to whirlpool scale from weapon progression
var whirlpool_scale_bonus: float = 0.0
## Bonus slow strength from weapon progression (negative = stronger slow)
var slow_strength_bonus: float = 0.0
## Modified slow effect with bonuses applied
var effective_slow_effect: SlowEffect
## Base scale of whirlpool (from animation end state)
const BASE_WHIRLPOOL_SCALE: float = 1.5
## Target scale including bonus
var target_whirlpool_scale: float = 1.5


func _ready() -> void:
	sprite.show()
	whirlpool_sprite.hide()
	whirlpool_sprite.top_level = true
	animation_player.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if is_dropping:
		global_position.y += drop_speed * delta
		
		# Track moving enemies
		if target_enemy and is_instance_valid(target_enemy):
			target_position = target_enemy.global_position
		
		if global_position.y >= target_position.y:
			_impact()
	else:
		# Update slow effects while whirlpool is active
		_update_slow_effects()
		
		# Auto-despawn after duration
		if whirlpool_sprite.visible:
			whirlpool_timer += delta
			if whirlpool_timer >= whirlpool_duration:
				start_shrink()


func setup_trident(spawn_pos: Vector2, target_pos: Vector2, target: Enemy, p_damage: int, p_drop_speed: float, p_slow_effect: SlowEffect, p_source: BaseWeapon, p_whirlpool_scale_bonus: float = 0.0, p_slow_strength_bonus: float = 0.0) -> void:
	global_position = spawn_pos
	target_position = target_pos
	target_enemy = target
	damage = p_damage
	drop_speed = p_drop_speed
	slow_effect = p_slow_effect
	source_weapon = p_source
	is_dropping = true
	whirlpool_scale_bonus = p_whirlpool_scale_bonus
	slow_strength_bonus = p_slow_strength_bonus
	
	# Create modified slow effect with bonus applied
	if slow_effect:
		effective_slow_effect = slow_effect.duplicate()
		# Apply slow strength bonus (negative bonus = stronger slow = lower multiplier)
		effective_slow_effect.slow_multiplier = clampf(slow_effect.slow_multiplier + slow_strength_bonus, 0.1, 0.9)
	else:
		effective_slow_effect = null


func _impact() -> void:
	is_dropping = false
	sprite.hide()
	
	whirlpool_sprite.global_position = global_position
	# Calculate target scale with bonus (applied after grow animation)
	target_whirlpool_scale = BASE_WHIRLPOOL_SCALE * (1.0 + whirlpool_scale_bonus)
	whirlpool_sprite.show()
	animation_player.play("grow")
	
	if target_enemy and is_instance_valid(target_enemy):
		target_enemy.take_damage(damage)
		if source_weapon and is_instance_valid(source_weapon):
			source_weapon.notify_enemy_hit(target_enemy)
	
	target_enemy = null


func _update_slow_effects() -> void:
	if not whirlpool_sprite.visible:
		return
	
	# Find enemies in the whirlpool area (scale includes bonus)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = SPRITE_SIZE * whirlpool_sprite.scale.x
	query.shape = shape
	query.transform = Transform2D(0, whirlpool_sprite.global_position)
	query.collision_mask = 4 # Enemy layer
	
	var results = space_state.intersect_shape(query)
	var enemies_in_range: Array[Enemy] = []
	
	# Apply slow to enemies in range (use effective_slow_effect with bonuses)
	var slow_to_apply = effective_slow_effect if effective_slow_effect else slow_effect
	for result in results:
		var enemy = result.collider
		if enemy is Enemy and is_instance_valid(enemy):
			enemies_in_range.append(enemy)
			if not affected_enemies.has(enemy):
				enemy.status_effects.apply_effect(slow_to_apply, self)
				affected_enemies.append(enemy)
	
	# Remove slow from enemies that left the area
	var indices_to_remove: Array[int] = []
	for i in range(affected_enemies.size()):
		var enemy = affected_enemies[i]
		if not is_instance_valid(enemy):
			indices_to_remove.append(i)
		elif not enemies_in_range.has(enemy):
			enemy.status_effects.remove_effects_from_source(self)
			indices_to_remove.append(i)
	
	# Remove in reverse order to preserve indices
	indices_to_remove.reverse()
	for i in indices_to_remove:
		affected_enemies.remove_at(i)


func _clear_slow_effects() -> void:
	for enemy in affected_enemies:
		if is_instance_valid(enemy):
			enemy.status_effects.remove_effects_from_source(self)
	affected_enemies.clear()


func start_shrink() -> void:
	if whirlpool_sprite.visible:
		# Reset to base scale before shrink animation (animation expects 1.5 start)
		whirlpool_sprite.scale = Vector2.ONE * BASE_WHIRLPOOL_SCALE
		animation_player.play("shrink")
	_clear_slow_effects()


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"grow":
		# Apply the bonus scale after grow animation completes
		whirlpool_sprite.scale = Vector2.ONE * target_whirlpool_scale
	elif anim_name == &"shrink":
		whirlpool_sprite.hide()
		destroy()
