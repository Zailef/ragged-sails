## Trident weapon that drops from above and creates a lingering whirlpool that slows enemies.
extends BaseWeapon
class_name Trident

const TridentProjectileScene = preload("res://scenes/weapons/projectiles/trident_projectile.tscn")

@export var drop_speed: float = 200.0
@export var drop_height_offset: float = 200.0
@export var targeting_radius: float = 150.0
@export var slow_effect: SlowEffect

var current_projectile: TridentProjectile = null


func _fire_weapon() -> void:
	var context: TargetingContext = TargetingContext.new()
	context.user = get_player()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats
	context.targeting_radius = targeting_radius

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_target():
		spawn_projectile(result.target)


func _activate() -> void:
	# Tell existing whirlpool to shrink before new one spawns
	if current_projectile and is_instance_valid(current_projectile):
		current_projectile.start_shrink()
		current_projectile = null
	
	end_active_phase()


func _reset_weapon() -> void:
	if current_projectile and is_instance_valid(current_projectile):
		current_projectile.start_shrink()
		current_projectile = null


func spawn_projectile(target: Enemy) -> void:
	var target_pos: Vector2 = target.global_position
	var spawn_pos: Vector2 = Vector2(target_pos.x, target_pos.y - drop_height_offset)
	
	var projectile: TridentProjectile = TridentProjectileScene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.setup_trident(spawn_pos, target_pos, target, weapon_stats.damage, drop_speed, slow_effect, self)
	
	current_projectile = projectile
