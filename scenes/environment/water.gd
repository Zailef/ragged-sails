@tool
extends Sprite2D

## Base tile density - tiles per unit of scale
@export var base_tile_density: float = 2.0:
	set(value):
		base_tile_density = value
		if is_inside_tree():
			update_shader_for_scale()

var _last_scale: Vector2 = Vector2.ZERO
var _runtime_material: ShaderMaterial

func _ready() -> void:
	# Make material unique so we don't modify the saved resource
	if material:
		_runtime_material = material.duplicate() as ShaderMaterial
		material = _runtime_material
	
	set_notify_transform(true)
	_last_scale = scale
	update_shader_for_scale()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if scale != _last_scale:
			_last_scale = scale
			update_shader_for_scale()

func calculate_aspect_ratio() -> void:
	var mat = _runtime_material if _runtime_material else material
	if not mat:
		return
	mat.set_shader_parameter("aspect_ratio", scale.y / scale.x)

func update_shader_for_scale() -> void:
	var mat = _runtime_material if _runtime_material else material
	if not mat:
		return
	# Keep consistent tile density regardless of scale
	var tiled_factor = scale * base_tile_density
	mat.set_shader_parameter("tiled_factor", tiled_factor)
	calculate_aspect_ratio()
