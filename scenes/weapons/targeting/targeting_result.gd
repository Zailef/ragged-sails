extends RefCounted
class_name TargetingResult

var target: Node = null
var direction: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO

func _init(p_target: Node = null, p_direction: Vector2 = Vector2.ZERO, p_position: Vector2 = Vector2.ZERO) -> void:
	target = p_target
	direction = p_direction
	position = p_position

func has_target() -> bool:
	return target != null

func has_direction() -> bool:
	return direction != Vector2.ZERO
