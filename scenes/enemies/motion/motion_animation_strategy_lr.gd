extends MotionAnimationStrategy
class_name MotionAnimationStrategyLR

@export var animation_name: String = "move_right"

func get_movement_animation(context: MotionAnimationStrategyContext) -> String:
	# Flip sprite based on horizontal direction
	if context.subject and is_instance_valid(context.subject) and context.subject.has_node("AnimatedSprite2D"):
		var sprite = context.subject.get_node("AnimatedSprite2D")
		if context.direction.x != 0:
			sprite.scale.x = abs(sprite.scale.x) * (-1 if context.direction.x < 0 else 1)

	return animation_name
