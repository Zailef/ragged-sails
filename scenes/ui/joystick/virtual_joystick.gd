extends Node2D

@export var bottom_offset: int = 70
@export var colour_override: Color = Color.TRANSPARENT
@export_range(0.01, 0.1) var size_percent: float = 0.03 ## Size as percentage of screen height

@onready var joystick_inner: Sprite2D = $JoystickInner
@onready var joystick_outer: Sprite2D = $JoystickOuter

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	
	var target_size = viewport_size.y * size_percent
	var base_size = 100.0
	var new_scale = target_size / base_size
	scale = Vector2(new_scale, new_scale)
	
	joystick_inner.max_length *= new_scale
	joystick_inner.deadzone *= new_scale
	
	position = Vector2(viewport_size.x / 2, viewport_size.y - bottom_offset - (target_size / 2))

	if colour_override != Color.TRANSPARENT:
		joystick_inner.self_modulate = colour_override
		joystick_outer.self_modulate = colour_override

var position_vector: Vector2 = Vector2.ZERO
var is_pressed: bool = false

func _on_joystick_inner_button_down() -> void:
	is_pressed = true

func _on_joystick_inner_button_up() -> void:
	is_pressed = false
