extends CharacterBody2D
class_name Enemy

var player: Player = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shader_material: ShaderMaterial = sprite.material as ShaderMaterial

@export var stats: EnemyStats
@export var loot_table: LootTable
@export var drop_strategy: DropStrategy = DropStrategyDefault.new()
@export var motion_animation_strategy: MotionAnimationStrategy = MotionAnimationStrategySingle.new()
@export var attack_animation_strategy: AttackAnimationStrategy = AttackAnimationStrategyNone.new()

@export_group("damage feedback")
@export var damage_flash_duration = 0.5
@export var damage_flash_strength = 0.5

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

func _handle_animations(direction: Vector2) -> void:
	var new_animation: String = ""

	if is_player_in_hurt_area:
		var context = AttackAnimationStrategyContext.new()
		context.subject = self
		context.target = player
		new_animation = attack_animation_strategy.get_attack_animation(context)
	else:
		var context = MotionAnimationStrategyContext.new()
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
	if damage_rate_timer >= stats.damage_rate:
		player.take_damage(stats.damage)
		damage_rate_timer = 0.0

func _handle_self_damage(amount: int) -> void:
	current_health -= amount

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

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
