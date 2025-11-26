extends TargetingStrategy
class_name TargetingStrategySide

enum Side {LEFT, RIGHT, BOTH}

@export var side := Side.RIGHT

func get_target(context: TargetingContext) -> TargetingResult:
	var player: Player = context.user as Player
	var facing_direction: Vector2

	if player.velocity.length() > 0.1:
		facing_direction = player.velocity.normalized()
	else:
		# When stationary, get the last facing direction from animation tree
		if player.animation_tree:
			facing_direction = player.animation_tree.get("parameters/Idle/blend_position")

		if facing_direction == Vector2.ZERO:
			facing_direction = Vector2.UP

	var direction: Vector2
	match side:
		Side.RIGHT:
			# Rotate 90 degrees counter-clockwise
			direction = Vector2(-facing_direction.y, facing_direction.x)
		Side.LEFT:
			# Rotate 90 degrees clockwise
			direction = Vector2(facing_direction.y, -facing_direction.x)
		Side.BOTH:
			# TODO: Weapons need a bit of a refactor for better projectile control
			push_error("TargetingStrategySide: BOTH side not fully implemented, defaulting to RIGHT side.")
			direction = Vector2(-facing_direction.y, facing_direction.x)

	return TargetingResult.new(null, direction, player.global_position)
