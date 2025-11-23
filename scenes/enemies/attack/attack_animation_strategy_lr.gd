extends AttackAnimationStrategy
class_name AttackAnimationStrategyLR

func get_attack_animation(context: AttackAnimationStrategyContext) -> String:
	if context.target.global_position.x < context.subject.global_position.x:
		return "attack_left"
	else:
		return "attack_right"
