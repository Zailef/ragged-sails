extends AttackAnimationStrategy
class_name AttackAnimationStrategyLR

@export var animation_name: String = "attack_right"

func get_attack_animation(context: AttackAnimationStrategyContext) -> String:
	# Flip sprite based on target position
	if context.subject and is_instance_valid(context.subject) and context.target and is_instance_valid(context.target) and context.subject.has_node("AnimatedSprite2D"):
		var sprite = context.subject.get_node("AnimatedSprite2D")
		sprite.scale.x = -1 if context.target.global_position.x < context.subject.global_position.x else 1
	
	return animation_name
