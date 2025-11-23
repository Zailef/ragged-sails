extends MotionAnimationStrategy
class_name MotionAnimationStrategyUDLR

func get_movement_animation(context: MotionAnimationStrategyContext) -> String:
	if abs(context.direction.x) > abs(context.direction.y):
		return "move_right" if context.direction.x > 0 else "move_left"
	else:
		return "move_down" if context.direction.y > 0 else "move_up"
