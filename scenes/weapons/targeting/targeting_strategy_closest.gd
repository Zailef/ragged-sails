extends TargetingStrategy
class_name TargetingStrategyClosest

func get_target(context: TargetingContext) -> TargetingResult:
	var enemies = context.enemies
	var nearest_enemy: Enemy = null
	var nearest_distance: float = INF

	for enemy in enemies:
		if not enemy.is_on_screen:
			continue
			
		var distance: float = context.user.global_position.distance_to(enemy.global_position)
		
		if context.weapon_stats and context.weapon_stats.max_range > 0:
			if distance > context.weapon_stats.max_range:
				continue
		
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	return TargetingResult.new(nearest_enemy)
