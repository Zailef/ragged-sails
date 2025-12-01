extends BaseWeapon
class_name Grapeshot

## The projectile scene to spawn
const VOLLEY_SCENE = preload("res://scenes/weapons/projectiles/grapeshot_volley.tscn")

## Container node for spawned projectiles (found at runtime)
var _projectile_container: Node = null

## Last fired direction (for upgrades like Broadside)
var last_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	super ()
	_projectile_container = get_tree().get_first_node_in_group("projectile_container")
	if not _projectile_container:
		_projectile_container = get_tree().current_scene


func _fire_weapon() -> void:
	# Use targeting strategy to get the direction
	var context: TargetingContext = TargetingContext.new()
	context.user = get_player()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats

	var result: TargetingResult = targeting_strategy.get_target(context)

	var direction: Vector2
	if result.has_direction():
		direction = result.direction
	else:
		# Fallback to right if no direction provided
		direction = Vector2.RIGHT

	last_direction = direction
	_spawn_volley(get_player().global_position, direction)


## Spawn a grapeshot volley at the given position and direction
func spawn_volley(spawn_pos: Vector2, dir: Vector2) -> void:
	_spawn_volley(spawn_pos, dir)


## Queue a volley to fire after a delay (used by upgrades like Broadside)
func queue_volley(direction: Vector2, delay: float) -> void:
	var timer = get_tree().create_timer(delay)
	await timer.timeout
	if is_instance_valid(self):
		_spawn_volley(get_player().global_position, direction)


func _spawn_volley(spawn_position: Vector2, direction: Vector2) -> void:
	var volley = VOLLEY_SCENE.instantiate() as GrapeshotVolley
	_projectile_container.add_child(volley)
	
	volley.global_position = spawn_position
	volley.setup(direction, get_effective_damage(), 0, -1, self)


func _reset_weapon() -> void:
	# Nothing to reset - volleys manage themselves
	pass


func _activate() -> void:
	# Immediately end active phase since we're just an orchestrator
	end_active_phase()
