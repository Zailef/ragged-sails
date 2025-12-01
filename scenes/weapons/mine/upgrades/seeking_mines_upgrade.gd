## Seeking Mines - Mines slowly move towards nearby enemies.
extends WeaponUpgrade
class_name SeekingMinesUpgrade

@export var seek_speed: float = 35.0 # Slow movement speed
@export var seek_range: float = 150.0 # Detection range for enemies


func on_physics_process(weapon: BaseWeapon, delta: float) -> void:
	var mine_weapon = weapon as Mine
	if not mine_weapon:
		return
	
	for mine in mine_weapon.mines:
		if not is_instance_valid(mine):
			continue
		
		# Don't seek if already detonating
		if mine.is_detonating:
			continue
		
		# Find nearest enemy
		var nearest_enemy: Enemy = _find_nearest_enemy(mine)
		if nearest_enemy:
			var direction = (nearest_enemy.global_position - mine.global_position).normalized()
			mine.global_position += direction * seek_speed * delta


func _find_nearest_enemy(mine: MineProjectile) -> Enemy:
	var enemies = mine.get_tree().get_nodes_in_group("enemies")
	var nearest: Enemy = null
	var nearest_dist: float = seek_range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = mine.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	
	return nearest
