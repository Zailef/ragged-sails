extends Sprite2D

signal button_down
signal button_up

@export var max_length: float = 50.0
@export var deadzone: float = 5.0
@export var return_speed: float = 10.0

@onready var joystick_parent: Node2D = get_parent()

func _process(delta: float) -> void:
	if joystick_parent.is_pressed:
		if get_global_mouse_position().distance_to(joystick_parent.global_position) <= max_length:
			global_position = get_global_mouse_position()
		else:
			var angle = joystick_parent.global_position.angle_to_point(get_global_mouse_position())
			global_position = joystick_parent.global_position + Vector2(cos(angle), sin(angle)) * max_length

		_calculate_vector()
	else:
		global_position = lerp(global_position, joystick_parent.global_position, delta * return_speed)
		joystick_parent.position_vector = joystick_parent.position_vector.move_toward(Vector2.ZERO, delta * return_speed)

func _calculate_vector() -> void:
	if abs(global_position.x - joystick_parent.global_position.x) >= deadzone:
		joystick_parent.position_vector.x = (global_position.x - joystick_parent.global_position.x) / max_length

	if abs(global_position.y - joystick_parent.global_position.y) >= deadzone:
		joystick_parent.position_vector.y = (global_position.y - joystick_parent.global_position.y) / max_length

func _on_button_button_up() -> void:
	button_up.emit()

func _on_button_button_down() -> void:
	button_down.emit()
