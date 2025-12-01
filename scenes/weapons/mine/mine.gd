extends BaseWeapon
class_name Mine

## The projectile scene to spawn
const MINE_SCENE = preload("res://scenes/weapons/projectiles/mine_projectile.tscn")

## Distance behind player to launch secondary mines
@export var rear_launch_distance: float = 60.0

## Container node for spawned projectiles (found at runtime)
var _projectile_container: Node = null

## Last movement direction for placing rear mines
var _last_direction: Vector2 = Vector2.DOWN

## Active mines for upgrades to reference
var mines: Array[MineProjectile] = []


func _ready() -> void:
	super ()
	_projectile_container = get_tree().get_first_node_in_group("projectile_container")
	if not _projectile_container:
		_projectile_container = get_tree().current_scene


func _physics_process(delta: float) -> void:
	super (delta)
	# Track player movement direction
	var player = get_player()
	if player and player.velocity.length() > 10:
		_last_direction = player.velocity.normalized()
	
	# Clean up destroyed mines from tracking array
	for i in range(mines.size() - 1, -1, -1):
		if not is_instance_valid(mines[i]):
			mines.remove_at(i)


func _fire_weapon() -> void:
	spawn_mine_at_player()


func spawn_mine_at_player() -> void:
	_spawn_mine(get_player().global_position)


func spawn_mine_behind_player() -> void:
	var player_pos = get_player().global_position
	var behind_pos = player_pos - _last_direction * rear_launch_distance
	_spawn_mine(behind_pos)


func spawn_mine_ahead_of_player() -> void:
	var player_pos = get_player().global_position
	var ahead_pos = player_pos + _last_direction * rear_launch_distance
	_spawn_mine(ahead_pos)


func _spawn_mine(spawn_position: Vector2) -> void:
	var mine = MINE_SCENE.instantiate() as MineProjectile
	_projectile_container.add_child(mine)
	
	mine.global_position = spawn_position
	mine.setup(Vector2.ZERO, get_effective_damage(), 0, -1, self)
	
	# Track active mines for upgrades
	mines.append(mine)


func _reset_weapon() -> void:
	# Nothing to reset - mines manage themselves
	pass


func _activate() -> void:
	# Immediately end active phase since we're just an orchestrator
	end_active_phase()
