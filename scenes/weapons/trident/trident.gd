extends Weapon
class_name Trident

const SPRITE_SIZE: int = 32

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var whirlpool_sprite: AnimatedSprite2D = $WhirlpoolSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var drop_speed: float = 200.0
@export var drop_height_offset: float = 200.0
@export var targeting_radius: float = 150.0
@export var slow_effect: SlowEffect

var is_dropping: bool = false
var target_enemy: Enemy = null
var target_position: Vector2 = Vector2.ZERO
var affected_enemies: Array[Enemy] = []

func _ready() -> void:
	super ()
	sprite.hide()
	whirlpool_sprite.hide()
	whirlpool_sprite.top_level = true
	animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if current_state != WeaponState.ACTIVE:
		# Update slow effects during cooldown
		if current_state == WeaponState.COOLDOWN:
			_update_slow_effects()
		return

	if is_dropping:
		global_position.y += drop_speed * delta

		# Update target position if enemy is still alive (track moving enemies)
		if target_enemy and is_instance_valid(target_enemy):
			target_position = target_enemy.global_position

		if global_position.y >= target_position.y:
			_impact()

func _fire_weapon() -> void:
	var context: TargetingContext = TargetingContext.new()
	context.user = get_owner()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats
	context.targeting_radius = targeting_radius

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_target():
		target_enemy = result.target
		target_position = target_enemy.global_position
		global_position = Vector2(target_position.x, target_position.y - drop_height_offset)
		rotation = 0.0
		is_dropping = true
	else:
		is_dropping = false
		target_enemy = null

func _activate() -> void:
	if whirlpool_sprite.visible:
		animation_player.play("shrink")
	_clear_slow_effects()

	if not is_dropping:
		end_active_phase()
		return

	sprite.play("default")
	sprite.show()

func _reset_weapon() -> void:
	is_dropping = false
	target_enemy = null
	target_position = Vector2.ZERO
	sprite.hide()

func _impact() -> void:
	is_dropping = false
	sprite.hide()

	whirlpool_sprite.global_position = global_position
	whirlpool_sprite.show()
	animation_player.play("grow")

	if target_enemy and is_instance_valid(target_enemy):
		target_enemy.take_damage(weapon_stats.damage)

	target_enemy = null
	end_active_phase()

func _update_slow_effects() -> void:
	if not whirlpool_sprite.visible:
		return
	
	# Find enemies in the whirlpool area
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = SPRITE_SIZE * whirlpool_sprite.scale.x
	query.shape = shape
	query.transform = Transform2D(0, whirlpool_sprite.global_position)
	query.collision_mask = 4 # Enemy layer

	var results = space_state.intersect_shape(query)
	var enemies_in_range: Array[Enemy] = []

	# Apply slow to enemies in range
	for result in results:
		var enemy = result.collider
		if enemy is Enemy and is_instance_valid(enemy):
			enemies_in_range.append(enemy)
			if not affected_enemies.has(enemy):
				# Apply the slow effect using the StatusEffectManager
				enemy.status_effects.apply_effect(slow_effect, self)
				affected_enemies.append(enemy)

	# Remove slow from enemies that left the area
	var enemies_to_remove: Array[Enemy] = []
	for enemy in affected_enemies:
		if not is_instance_valid(enemy) or not enemies_in_range.has(enemy):
			# Remove slow effect using the StatusEffectManager
			if is_instance_valid(enemy):
				enemy.status_effects.remove_effects_from_source(self)
			enemies_to_remove.append(enemy)

	for enemy in enemies_to_remove:
		affected_enemies.erase(enemy)

func _clear_slow_effects() -> void:
	# Remove slow from all affected enemies
	for enemy in affected_enemies:
		if is_instance_valid(enemy):
			enemy.status_effects.remove_effects_from_source(self)
	affected_enemies.clear()

## Called by StatusEffectManager when an enemy with our effect is freed
func _on_affected_entity_freed(enemy: Enemy) -> void:
	affected_enemies.erase(enemy)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"shrink":
		whirlpool_sprite.hide()
