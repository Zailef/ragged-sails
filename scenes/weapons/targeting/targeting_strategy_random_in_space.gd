extends TargetingStrategy
class_name TargetingStrategyRandomInSpace

func get_target(context: TargetingContext) -> TargetingResult:
	var valid_enemies: Array[Enemy] = []
	
	if not context.targeting_radius or not context.targeting_radius > 0.0:
		push_error("TargetingStrategyRandomInSpace requires a positive targeting_radius in TargetingContext.")
		return TargetingResult.new(null)

	if context.targeting_radius > 0.0:
		var space_state = context.user.get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius = context.targeting_radius
		query.shape = shape
		query.transform = Transform2D(0, context.user.global_position)
		query.collision_mask = 4 # Enemy layer (bit 2 = value 4)
		
		var results = space_state.intersect_shape(query)
		print("Space query found ", results.size(), " colliders")
		for result in results:
			var collider = result.collider
			print("  Collider: ", collider, " is Enemy: ", collider is Enemy)
			if collider is Enemy:
				valid_enemies.append(collider)
	
	if valid_enemies.size() == 0:
		return TargetingResult.new(null)
	
	var random_index: int = randi() % valid_enemies.size()
	var random_enemy: Enemy = valid_enemies[random_index]
	
	return TargetingResult.new(random_enemy)
