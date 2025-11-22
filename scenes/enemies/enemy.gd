extends CharacterBody2D
class_name Enemy

var player: Player = null

enum AttackAnimationMode {
	NONE,
	LR,
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var stats: EnemyStats
@export var animation_motion_strategy: MotionAnimationStrategy = MotionAnimationStrategySingle.new()
@export var attack_strategy: AttackAnimationMode = AttackAnimationMode.NONE

var is_target_left: bool = false:
	get: return player != null and player.global_position.x < global_position.x

var is_on_screen: bool = false
var is_player_in_hurt_area: bool = false
var damage_rate_timer: float = 0.0
var current_health: int

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_health = stats.max_health

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	if not is_player_in_hurt_area:
		velocity = direction * stats.move_speed
	else:
		velocity = Vector2.ZERO

	_handle_animations(direction)
	_handle_player_damage(delta)

	move_and_slide()

var _attack_strategies = {
	AttackAnimationMode.NONE: _attack_none,
	AttackAnimationMode.LR: _attack_lr
}

func _handle_animations(direction: Vector2) -> void:
	var new_animation: String = ""

	if is_player_in_hurt_area:
		var strategy = _attack_strategies.get(attack_strategy, _attack_none)
		new_animation = strategy.call()
	else:
		var context = MotionAnimationStrategyContext.new()
		context.direction = direction
		new_animation = animation_motion_strategy.get_movement_animation(context)

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

func _attack_none() -> String:
	return ""

func _attack_lr() -> String:
	return "attack_left" if is_target_left else "attack_right"

func _handle_player_damage(delta: float) -> void:
	if not is_player_in_hurt_area:
		return

	damage_rate_timer += delta
	if damage_rate_timer >= stats.damage_rate:
		player.take_damage(stats.damage)
		damage_rate_timer = 0.0

func _handle_self_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		SignalManager.enemy_defeated.emit()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
