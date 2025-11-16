extends CharacterBody2D
class_name Enemy

var player: Player = null

enum MotionAnimationMode {
	SINGLE,
	UDLR,
	LR,
}

enum AttackAnimationMode {
	NONE,
	LR,
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var stats: EnemyStats
@export var animation_mode: MotionAnimationMode = MotionAnimationMode.SINGLE
@export var attack_strategy: AttackAnimationMode = AttackAnimationMode.NONE

var is_target_left: bool = false:
	get: return player != null and player.global_position.x < global_position.x

var is_player_in_hurt_area: bool = false
var damage_rate_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	if not is_player_in_hurt_area:
		velocity = direction * stats.move_speed
	else:
		velocity = Vector2.ZERO

	_handle_animations(direction)
	_handle_damage(delta)
	move_and_slide()

var _animation_strategies = {
	MotionAnimationMode.SINGLE: _animation_single,
	MotionAnimationMode.UDLR: _animation_udlr,
	MotionAnimationMode.LR: _animation_lr
}

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
		var strategy = _animation_strategies.get(animation_mode, _animation_single)
		new_animation = strategy.call(direction)

	if sprite.animation != new_animation and new_animation != "":
		sprite.animation = new_animation

func _animation_single(_direction: Vector2) -> String:
	return "move"

func _animation_udlr(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "move_right" if direction.x > 0 else "move_left"
	else:
		return "move_down" if direction.y > 0 else "move_up"

func _animation_lr(direction: Vector2) -> String:
	return "move_right" if direction.x > 0 else "move_left"

func _on_hit_area_area_entered(_area: Area2D) -> void:
	is_player_in_hurt_area = true

func _on_hit_area_area_exited(_area: Area2D) -> void:
	is_player_in_hurt_area = false
	damage_rate_timer = 0.0

func _attack_none() -> String:
	return ""

func _attack_lr() -> String:
	return "attack_left" if is_target_left else "attack_right"

func _handle_damage(delta: float) -> void:
	if not is_player_in_hurt_area:
		return

	damage_rate_timer += delta
	if damage_rate_timer >= stats.damage_rate:
		player.take_damage(stats.damage)
		damage_rate_timer = 0.0
