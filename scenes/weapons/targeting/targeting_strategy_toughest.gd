extends TargetingStrategy
class_name TargetingStrategyToughest

func get_target(context: TargetingContext) -> TargetingResult:
	var enemies = context.enemies
	var toughest_enemy: Enemy = null
	var highest_health: int = -1

	for enemy in enemies:
		if not enemy.is_on_screen:
			continue
		
		if context.weapon_stats and context.weapon_stats.max_range > 0:
			var distance = context.user.global_position.distance_to(enemy.global_position)
			if distance > context.weapon_stats.max_range:
				continue
		
		if enemy.current_health > highest_health:
			highest_health = enemy.current_health
			toughest_enemy = enemy

	return TargetingResult.new(toughest_enemy)
