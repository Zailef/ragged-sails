extends Weapon
class_name Grapeshot

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

var direction: Vector2 = Vector2.ZERO
var damaged_enemies: Array[Enemy] = []

func _ready() -> void:
	super ()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	shape_cast.enabled = false

func _physics_process(_delta: float) -> void:
	if current_state != WeaponState.ACTIVE:
		return

	shape_cast.force_shapecast_update()
	for i in range(shape_cast.get_collision_count()):
		var collider = shape_cast.get_collider(i)
		if collider.get_owner() is Enemy:
			var enemy: Enemy = collider.get_owner()
			if enemy not in damaged_enemies:
				enemy.take_damage(weapon_stats.damage)
				damaged_enemies.append(enemy)

func _fire_weapon() -> void:
	global_position = get_owner().global_position

	# Use targeting strategy to get the direction
	var context: TargetingContext = TargetingContext.new()
	context.user = get_owner()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_direction():
		direction = result.direction
		rotation = direction.angle()
	else:
		# Fallback to right if no direction provided
		direction = Vector2.RIGHT
		rotation = 0.0

func _reset_weapon() -> void:
	global_position = get_owner().global_position
	direction = Vector2.ZERO
	damaged_enemies.clear()
	shape_cast.enabled = false
	hide()

func _on_animation_finished() -> void:
	end_active_phase()

func _activate() -> void:
	if direction == Vector2.ZERO:
		return

	damaged_enemies.clear()
	shape_cast.enabled = true
	show()
	animated_sprite.play()
