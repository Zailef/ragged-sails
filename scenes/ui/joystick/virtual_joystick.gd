@tool
extends Node2D

@export var bottom_offset: int = 70:
	set(value):
		bottom_offset = value
		_update_joystick()

@export var left_offset: int = 70:
	set(value):
		left_offset = value
		_update_joystick()

@export var colour_override: Color = Color.TRANSPARENT:
	set(value):
		colour_override = value
		_update_joystick()

@export_range(0.01, 0.1) var size_percent: float = 0.03: ## Size as percentage of screen height
	set(value):
		size_percent = value
		_update_joystick()

@onready var joystick_inner: Sprite2D = $JoystickInner
@onready var joystick_outer: Sprite2D = $JoystickOuter

var position_vector: Vector2 = Vector2.ZERO
var is_pressed: bool = false
var _base_max_length: float = 0.0
var _base_deadzone: float = 0.0


func _ready() -> void:
	if joystick_inner:
		_base_max_length = joystick_inner.max_length
		_base_deadzone = joystick_inner.deadzone
	_update_joystick()


func _update_joystick() -> void:
	if not is_inside_tree():
		return
	
	var viewport_size = get_viewport_rect().size
	
	var target_size = viewport_size.y * size_percent
	var base_size = 100.0
	var new_scale = target_size / base_size
	scale = Vector2(new_scale, new_scale)
	
	if joystick_inner and _base_max_length > 0:
		joystick_inner.max_length = _base_max_length * new_scale
		joystick_inner.deadzone = _base_deadzone * new_scale
	
	position = Vector2(left_offset + (target_size / 2), viewport_size.y - bottom_offset - (target_size / 2))

	if joystick_inner and joystick_outer and colour_override != Color.TRANSPARENT:
		joystick_inner.self_modulate = colour_override
		joystick_outer.self_modulate = colour_override

func _on_joystick_inner_button_down() -> void:
	is_pressed = true

func _on_joystick_inner_button_up() -> void:
	is_pressed = false
