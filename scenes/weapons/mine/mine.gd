extends BaseWeapon
class_name Mine

## The projectile scene to spawn
const MINE_SCENE = preload("res://scenes/weapons/projectiles/mine_projectile.tscn")

## Container node for spawned projectiles (found at runtime)
var _projectile_container: Node = null


func _ready() -> void:
	super()
	_projectile_container = get_tree().get_first_node_in_group("projectile_container")
	if not _projectile_container:
		_projectile_container = get_tree().current_scene


func _fire_weapon() -> void:
	_spawn_mine(get_player().global_position)


func _spawn_mine(spawn_position: Vector2) -> void:
	var mine = MINE_SCENE.instantiate() as MineProjectile
	_projectile_container.add_child(mine)
	
	mine.global_position = spawn_position
	mine.setup(Vector2.ZERO, get_effective_damage(), 0, -1, self)


func _reset_weapon() -> void:
	# Nothing to reset - mines manage themselves
	pass


func _activate() -> void:
	# Immediately end active phase since we're just an orchestrator
	end_active_phase()
