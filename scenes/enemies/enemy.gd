extends CharacterBody2D
class_name Enemy

const BOSS_DAMAGE_OUTLINE_SHADER = preload("res://sprites/shaders/boss_damage_outline.gdshader")

var player: Player = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shader_material: ShaderMaterial = sprite.material as ShaderMaterial
@onready var status_effects: StatusEffectManager = $StatusEffectManager
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area_collision_shape: CollisionShape2D = $HitArea/CollisionShape2D

@export var stats: EnemyStats
@export var is_boss: bool = false
@export var loot_table: LootTable
@export var drop_strategy: DropStrategy = DropStrategyDefault.new()
@export var motion_animation_strategy: MotionAnimationStrategy = MotionAnimationStrategySingle.new()
@export var attack_animation_strategy: AttackAnimationStrategy = AttackAnimationStrategyNone.new()

@export_group("Damage Feedback")
@export var damage_flash_duration = 0.5
@export var damage_flash_strength = 0.5

@export_group("collision")
## If true, collision shapes rotate to match movement direction (for elongated enemies like sharks)
@export var rotate_collision_with_direction: bool = false
## Position offset for collision shape when facing horizontally (left/right)
@export var horizontal_collision_offset: Vector2 = Vector2.ZERO
## Position offset for collision shape when facing vertically (up/down)
@export var vertical_collision_offset: Vector2 = Vector2.ZERO

var is_on_screen: bool = false
var is_player_in_hurt_area: bool = false
var damage_rate_timer: float = 0.0
var current_health: int

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_health = stats.get_max_health(is_boss)
	scale *= stats.get_scale(is_boss)

	if is_boss:
		_apply_boss_outline()

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	if not is_player_in_hurt_area:
		velocity = direction * get_effective_speed()
	else:
		velocity = Vector2.ZERO

	_handle_animations(direction)
	_handle_player_damage(delta)
	
	if rotate_collision_with_direction and direction != Vector2.ZERO:
		_update_collision_rotation(direction)

	move_and_slide()

## Gets the effective movement speed after applying all status effects
func get_effective_speed() -> float:
	return stats.get_move_speed(is_boss) * status_effects.get_speed_multiplier()

## Gets the effective damage taken multiplier after applying all status effects
func get_damage_taken_multiplier() -> float:
	return status_effects.get_damage_taken_multiplier()

## Gets the effective damage dealt multiplier after applying all status effects
func get_damage_dealt_multiplier() -> float:
	return status_effects.get_damage_dealt_multiplier()

func take_damage(amount: int) -> void:
	_handle_self_damage(amount)

func _update_collision_rotation(direction: Vector2) -> void:
	# Snap rotation to match UDLR sprite directions (not continuous rotation)
	# Capsule default orientation is vertical (pointing up/down)
	var target_rotation: float
	var target_offset: Vector2
	
	if abs(direction.x) > abs(direction.y):
		# Horizontal (left or right) - rotate capsule 90 degrees
		target_rotation = PI / 2.0
		target_offset = horizontal_collision_offset
		# Mirror offset for left direction
		if direction.x < 0:
			target_offset.x = - target_offset.x
	else:
		# Vertical (up or down) - keep capsule vertical
		target_rotation = 0.0
		target_offset = vertical_collision_offset
	
	if collision_shape:
		collision_shape.rotation = target_rotation
		collision_shape.position = target_offset
	if hit_area_collision_shape:
		hit_area_collision_shape.rotation = target_rotation
		hit_area_collision_shape.position = target_offset

func _handle_animations(direction: Vector2) -> void:
	var new_animation: String = ""

	if is_player_in_hurt_area:
		var context = AttackAnimationStrategyContext.new()
		context.subject = self
		context.target = player
		new_animation = attack_animation_strategy.get_attack_animation(context)
	else:
		var context = MotionAnimationStrategyContext.new()
		context.subject = self
		context.direction = direction
		new_animation = motion_animation_strategy.get_movement_animation(context)

	if sprite.animation != new_animation and new_animation != "":
		sprite.animation = new_animation
		sprite.play()

func _on_hit_area_area_entered(area: Area2D) -> void:
	if area.get_owner() is Player:
		is_player_in_hurt_area = true

	if area.get_owner() is BaseWeapon:
		var weapon: BaseWeapon = area.get_owner() as BaseWeapon
		_handle_self_damage(weapon.weapon_stats.damage)

func _on_hit_area_area_exited(area: Area2D) -> void:
	if area.get_owner() is Player:
		is_player_in_hurt_area = false
		damage_rate_timer = 0.0

func _handle_player_damage(delta: float) -> void:
	if not is_player_in_hurt_area:
		return

	damage_rate_timer += delta
	if damage_rate_timer >= stats.get_damage_rate(is_boss):
		player.take_damage(stats.get_damage(is_boss))
		damage_rate_timer = 0.0

func _handle_self_damage(amount: int) -> void:
	current_health -= int(amount * get_damage_taken_multiplier())

	damage_shader_material.set_shader_parameter("flash_strength", damage_flash_strength)
	var tween := create_tween()
	tween.tween_property(damage_shader_material, "shader_parameter/flash_strength", 0.0, damage_flash_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if current_health <= 0:
		SignalManager.enemy_defeated.emit()
		var context = DropStrategyContext.new()
		context.enemy = self
		drop_strategy.perform_drops(context)
		queue_free.call_deferred()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false

func _apply_boss_outline() -> void:
	var boss_material = ShaderMaterial.new()
	boss_material.shader = BOSS_DAMAGE_OUTLINE_SHADER
	sprite.material = boss_material
	damage_shader_material = boss_material

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
