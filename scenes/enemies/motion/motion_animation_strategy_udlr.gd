extends MotionAnimationStrategy
class_name MotionAnimationStrategyUDLR

func get_movement_animation(context: MotionAnimationStrategyContext) -> String:
	if abs(context.direction.x) > abs(context.direction.y):
		# Flip sprite based on horizontal direction
		if context.subject and is_instance_valid(context.subject) and context.subject.has_node("AnimatedSprite2D"):
			var sprite = context.subject.get_node("AnimatedSprite2D")
			sprite.scale.x = abs(sprite.scale.x) * (-1 if context.direction.x < 0 else 1)
		return "move_right"
	else:
		return "move_down" if context.direction.y > 0 else "move_up"
