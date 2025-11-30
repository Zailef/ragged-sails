extends CanvasLayer
class_name BoundaryWarningOverlay

## Visual feedback when player approaches map boundaries.

@export var boundary_manager_path: NodePath
@export var fade_duration: float = 0.3

@onready var color_rect: ColorRect = $ColorRect

var boundary_manager: BoundaryManager
var _tween: Tween
var _current_zone: String = "safe"

func _ready() -> void:
	# Start fully transparent
	color_rect.color = Color(0, 0, 0, 0)
	
	# Connect to signal manager for zone changes
	SignalManager.boundary_zone_changed.connect(_on_zone_changed)
	
	# Find boundary manager
	if boundary_manager_path:
		boundary_manager = get_node(boundary_manager_path) as BoundaryManager
	
	if boundary_manager:
		boundary_manager.zone_depth_changed.connect(_on_depth_changed)

func _on_zone_changed(zone: String) -> void:
	_current_zone = zone
	
	if not boundary_manager or not boundary_manager.config:
		return
	
	var target_color: Color
	
	match zone:
		"safe":
			target_color = Color(0, 0, 0, 0)
		"warning":
			target_color = boundary_manager.config.warning_tint_color
		"danger":
			target_color = boundary_manager.config.danger_tint_color
		"death":
			target_color = Color(0.8, 0, 0, 0.8)
		_:
			target_color = Color(0, 0, 0, 0)
	
	_tween_to_color(target_color)

func _on_depth_changed(depth: float) -> void:
	# Gradually intensify the effect based on depth
	if not boundary_manager or not boundary_manager.config:
		return
	
	if _current_zone == "safe":
		return
	
	var config = boundary_manager.config
	var base_color: Color
	
	match _current_zone:
		"warning":
			base_color = config.warning_tint_color
		"danger":
			base_color = config.danger_tint_color
		_:
			return
	
	# Intensify alpha based on depth
	var intensified = base_color
	intensified.a = lerpf(base_color.a * 0.5, base_color.a, depth)
	color_rect.color = intensified

func _tween_to_color(target: Color) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(color_rect, "color", target, fade_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
