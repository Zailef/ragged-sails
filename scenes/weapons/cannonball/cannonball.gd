extends BaseWeapon
class_name Cannonball

## The projectile scene to spawn
const PROJECTILE_SCENE = preload("res://scenes/weapons/projectiles/cannonball_projectile.tscn")

@onready var cannon_fire_sound: AudioStreamPlayer = $CannonFireSound

## Container node for spawned projectiles (found at runtime)
var _projectile_container: Node = null

## Last fired direction (for upgrades)
var last_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	super ()
	# Find or create a container for projectiles in the scene tree
	_projectile_container = get_tree().get_first_node_in_group("projectile_container")
	if not _projectile_container:
		_projectile_container = get_tree().current_scene


func _fire_weapon() -> void:
	var context: TargetingContext = TargetingContext.new()
	context.user = get_player()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_target():
		var spawn_pos = get_player().global_position
		var direction = (result.target.global_position - spawn_pos).normalized()
		last_direction = direction
		_spawn_projectile(spawn_pos, direction)


func _spawn_projectile(spawn_position: Vector2, direction: Vector2) -> void:
	var projectile = PROJECTILE_SCENE.instantiate() as CannonballProjectile
	_projectile_container.add_child(projectile)

	projectile.global_position = spawn_position
	projectile.setup(
		direction,
		get_effective_damage(),
		get_effective_speed(),
		get_effective_range(),
		self,
		get_effective_penetration()
	)

	cannon_fire_sound.play()


## Queue a cannonball to fire after a delay (used by upgrades)
func queue_cannonball(delay: float) -> void:
	var timer = get_tree().create_timer(delay)
	await timer.timeout
	if is_instance_valid(self) and last_direction != Vector2.ZERO:
		_spawn_projectile(get_player().global_position, last_direction)


func _reset_weapon() -> void:
	# Nothing to reset - projectiles manage themselves
	pass


func _activate() -> void:
	# Activation is handled by _fire_weapon spawning the projectile
	# Immediately end active phase since we're just an orchestrator
	end_active_phase()
