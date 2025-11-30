extends Sprite2D
class_name BoundaryArrow

## Visual indicator that appears when player approaches map boundaries.
## Points toward the safe zone and positions itself at the screen edge
## closest to the boundary being approached.

@export var edge_offset: float = 100.0 ## Distance from screen edge in world units

var _player: Node2D = null
var _boundary_manager: BoundaryManager = null

func _ready() -> void:
	visible = false
	set_process(false)
	_find_references.call_deferred()

func _find_references() -> void:
	# Find player (our parent)
	_player = get_parent() as Node2D
	
	# Find boundary manager
	_boundary_manager = get_tree().get_first_node_in_group("boundary_manager") as BoundaryManager
	
	# Connect to zone change signal for efficient updates
	SignalManager.boundary_zone_changed.connect(_on_zone_changed)

func _on_zone_changed(zone: String) -> void:
	if zone == "safe":
		visible = false
		set_process(false)
	else:
		set_process(true)
		_update_arrow()

func _process(_delta: float) -> void:
	if not _player or not _boundary_manager:
		return
	
	_update_arrow()

func _update_arrow() -> void:
	var zone = _boundary_manager.get_current_zone()

	if zone == "safe":
		visible = false
		return
	
	visible = true
	# Point arrow toward safe zone center
	var safe_zone_center = _boundary_manager.get_effective_safe_zone().get_center()
	var direction_to_safe = (safe_zone_center - _player.global_position).normalized()
	# Arrow sprite points up, so rotate to point toward safe zone
	rotation = direction_to_safe.angle() + PI / 2.0
	# Position arrow at edge of screen toward the boundary
	position = _get_screen_edge_position(direction_to_safe)

func _get_screen_edge_position(direction_to_safe: Vector2) -> Vector2:
	# Get viewport size and camera zoom to calculate visible screen bounds
	var viewport_size = get_viewport_rect().size
	var camera = get_viewport().get_camera_2d()
	var zoom = camera.zoom if camera else Vector2.ONE
	
	# Half-size of visible area in world coordinates (relative to player)
	var half_width = (viewport_size.x / zoom.x) / 2.0
	var half_height = (viewport_size.y / zoom.y) / 2.0
	
	# Direction toward danger (opposite of safe)
	var danger_dir = - direction_to_safe
	
	# Calculate position at the screen edge toward the danger direction
	# Use the dominant axis to determine which edge to anchor to
	var arrow_pos = Vector2.ZERO
	
	if abs(danger_dir.x) > abs(danger_dir.y):
		# Horizontal boundary (left or right edge)
		arrow_pos.x = sign(danger_dir.x) * (half_width - edge_offset)
		arrow_pos.y = clamp(danger_dir.y * half_height * 0.5, -half_height + edge_offset, half_height - edge_offset)
	else:
		# Vertical boundary (top or bottom edge)
		arrow_pos.y = sign(danger_dir.y) * (half_height - edge_offset)
		arrow_pos.x = clamp(danger_dir.x * half_width * 0.5, -half_width + edge_offset, half_width - edge_offset)
	
	return arrow_pos
