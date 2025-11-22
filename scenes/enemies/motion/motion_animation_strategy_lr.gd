extends MotionAnimationStrategy
class_name MotionAnimationStrategyLR

func get_movement_animation(context: MotionAnimationStrategyContext) -> String:
	return "move_right" if context.direction.x > 0 else "move_left"
