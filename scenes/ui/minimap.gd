extends Control
class_name Minimap

## A minimap that shows the player, enemies, and obstacles in a top-down view.
## Uses manual drawing for efficiency rather than a SubViewport.
## Position this Control wherever you want in the UI - anchors are respected.

@export_group("Display")
## Size of the minimap display in pixels
@export var minimap_size: Vector2 = Vector2(150, 150):
	set(value):
		minimap_size = value
		custom_minimum_size = value
		queue_redraw()
## How much of the world to show (in world units from center)
@export var view_radius: float = 800.0

@export_group("Icons")
## Player icon size
@export var player_icon_size: float = 5.0
## Enemy icon size
@export var enemy_icon_size: float = 2.0
## Obstacle icon size
@export var obstacle_icon_size: float = 4.0
## Chest icon size
@export var chest_icon_size: float = 3.0

@export_group("Colors")
@export var background_color: Color = Color(0.1, 0.15, 0.25, 0.8)
@export var border_color: Color = Color(0.8, 0.7, 0.5, 1.0)
@export var player_color: Color = Color(0.2, 0.8, 0.3, 1.0)
@export var enemy_color: Color = Color(0.9, 0.2, 0.2, 1.0)
@export var boss_color: Color = Color(1.0, 0.4, 0.0, 1.0)
@export var rock_color: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var shipwreck_color: Color = Color(0.5, 0.4, 0.3, 1.0)
@export var chest_color: Color = Color(1.0, 0.85, 0.2, 1.0)
@export var boundary_color: Color = Color(0.3, 0.5, 0.7, 0.5)

@export_group("References")
@export var player_path: NodePath
@export var enemies_container_path: NodePath
@export var obstacles_container_path: NodePath
@export var boundary_manager_path: NodePath

var player: Player
var enemies_container: Node2D
var obstacles_container: Node2D
var boundary_manager: BoundaryManager

var _cached_obstacles: Array[Node2D] = []
var _obstacle_cache_timer: float = 0.0
const OBSTACLE_CACHE_INTERVAL: float = 1.0


func _ready() -> void:
	# Set minimum size so the Control knows how big we want to be
	custom_minimum_size = minimap_size
	
	# Get references (deferred to ensure scene is ready)
	_setup_references.call_deferred()


func _setup_references() -> void:
	# Find player
	if player_path:
		player = get_node_or_null(player_path) as Player
	if not player:
		player = get_tree().get_first_node_in_group("player") as Player
	
	# Find enemies container - try path first, then search by name in scene root
	if enemies_container_path:
		enemies_container = get_node_or_null(enemies_container_path) as Node2D
	if not enemies_container:
		# Search in the main scene for a node named "Enemies"
		var root = get_tree().current_scene
		if root:
			enemies_container = root.get_node_or_null("Enemies") as Node2D
	
	# Find obstacles container
	if obstacles_container_path:
		obstacles_container = get_node_or_null(obstacles_container_path) as Node2D
	if not obstacles_container:
		var root = get_tree().current_scene
		if root:
			obstacles_container = root.get_node_or_null("Obstacles") as Node2D
	
	# Find boundary manager
	if boundary_manager_path:
		boundary_manager = get_node_or_null(boundary_manager_path) as BoundaryManager
	if not boundary_manager:
		boundary_manager = get_tree().get_first_node_in_group("boundary_manager") as BoundaryManager
	
	_update_obstacle_cache()


func _process(delta: float) -> void:
	# Periodically refresh obstacle cache (obstacles don't move often)
	_obstacle_cache_timer += delta
	if _obstacle_cache_timer >= OBSTACLE_CACHE_INTERVAL:
		_obstacle_cache_timer = 0.0
		_update_obstacle_cache()
	
	# Redraw every frame
	queue_redraw()


func _update_obstacle_cache() -> void:
	_cached_obstacles.clear()
	if obstacles_container:
		for child in obstacles_container.get_children():
			# ObjectScatter node contains scattered objects
			if child.has_method("get_children"):
				for obstacle in child.get_children():
					if obstacle is Node2D:
						_cached_obstacles.append(obstacle)
			elif child is Node2D:
				_cached_obstacles.append(child)


func _draw() -> void:
	if not player:
		return
	
	var draw_size = size # Use actual Control size, not export
	var center = draw_size / 2.0
	var scale_factor = draw_size.x / (view_radius * 2.0)
	
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, draw_size), background_color)
	
	# Enable clipping so nothing draws outside the minimap bounds
	var clip_rect = Rect2(Vector2.ZERO, draw_size)
	draw_set_transform(Vector2.ZERO)
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, clip_rect)
	
	# Draw boundary only when it's visible on the minimap (player near edge)
	if boundary_manager:
		_draw_boundary_if_visible(center, scale_factor, draw_size)
	
	# Draw obstacles (rocks as gray squares, shipwrecks as brown circles)
	for obstacle in _cached_obstacles:
		if is_instance_valid(obstacle):
			_draw_obstacle(obstacle, center, scale_factor, draw_size)
	
	# Draw chests as gold squares
	for chest in get_tree().get_nodes_in_group("chests"):
		if is_instance_valid(chest) and chest is Node2D:
			var minimap_pos = _world_to_minimap(chest.global_position, player.global_position, center, scale_factor)
			if minimap_pos.x >= -chest_icon_size and minimap_pos.x <= draw_size.x + chest_icon_size \
				and minimap_pos.y >= -chest_icon_size and minimap_pos.y <= draw_size.y + chest_icon_size:
				var half_size = chest_icon_size * 0.8
				var rect = Rect2(minimap_pos - Vector2(half_size, half_size), Vector2(half_size * 2, half_size * 2))
				draw_rect(rect, chest_color)
	
	# Draw enemies
	if enemies_container:
		for enemy_node in enemies_container.get_children():
			var enemy := enemy_node as Enemy
			if enemy and is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				var color = boss_color if enemy.is_boss else enemy_color
				var icon_size = enemy_icon_size * (1.5 if enemy.is_boss else 1.0)
				_draw_icon(enemy.global_position, center, scale_factor, color, icon_size, draw_size)
	
	# Draw player (always on top, always at center)
	_draw_player_icon(center)
	
	# Draw border
	draw_rect(Rect2(Vector2.ZERO, draw_size), border_color, false, 2.0)


func _draw_boundary_if_visible(center: Vector2, scale_factor: float, _draw_size: Vector2) -> void:
	var safe_zone = boundary_manager.get_effective_safe_zone()
	var player_pos = player.global_position
	
	# Check if any edge of the boundary is within our view radius
	var distance_to_left = player_pos.x - safe_zone.position.x
	var distance_to_right = safe_zone.end.x - player_pos.x
	var distance_to_top = player_pos.y - safe_zone.position.y
	var distance_to_bottom = safe_zone.end.y - player_pos.y
	
	var min_distance = min(distance_to_left, distance_to_right, distance_to_top, distance_to_bottom)
	
	# Only draw if the boundary edge is within the minimap's view
	if min_distance > view_radius:
		return
	
	# Convert safe zone corners to minimap coordinates
	var top_left = _world_to_minimap(safe_zone.position, player_pos, center, scale_factor)
	var zone_size = safe_zone.size * scale_factor
	
	# Draw safe zone rectangle
	var rect = Rect2(top_left, zone_size)
	draw_rect(rect, boundary_color, false, 1.5)


func _draw_obstacle(obstacle: Node2D, center: Vector2, scale_factor: float, draw_size: Vector2) -> void:
	var minimap_pos = _world_to_minimap(obstacle.global_position, player.global_position, center, scale_factor)
	var icon_size = obstacle_icon_size
	
	# Only draw if within minimap bounds (with some padding)
	if minimap_pos.x < -icon_size or minimap_pos.x > draw_size.x + icon_size \
		or minimap_pos.y < -icon_size or minimap_pos.y > draw_size.y + icon_size:
		return
	
	# Check if it's a rock or shipwreck based on group membership
	if obstacle.is_in_group("rocks"):
		# Draw rocks as gray squares
		var half_size = icon_size * 0.8
		var rect = Rect2(minimap_pos - Vector2(half_size, half_size), Vector2(half_size * 2, half_size * 2))
		draw_rect(rect, rock_color)
	elif obstacle.is_in_group("shipwrecks"):
		# Draw shipwrecks as brown circles
		draw_circle(minimap_pos, icon_size, shipwreck_color)
	else:
		# Default fallback for unknown obstacles
		draw_circle(minimap_pos, icon_size, shipwreck_color)


func _draw_icon(world_pos: Vector2, center: Vector2, scale_factor: float, color: Color, icon_size: float, draw_size: Vector2) -> void:
	var minimap_pos = _world_to_minimap(world_pos, player.global_position, center, scale_factor)
	
	# Only draw if within minimap bounds (with some padding)
	if minimap_pos.x >= -icon_size and minimap_pos.x <= draw_size.x + icon_size \
		and minimap_pos.y >= -icon_size and minimap_pos.y <= draw_size.y + icon_size:
		draw_circle(minimap_pos, icon_size, color)


func _draw_player_icon(center: Vector2) -> void:
	# Player is always at center - draw as a triangle pointing in movement direction
	var direction = player.velocity.normalized() if player.velocity.length() > 0.1 else Vector2.UP
	
	# Triangle points
	var forward = direction * player_icon_size
	var left = direction.rotated(2.5) * player_icon_size * 0.6
	var right = direction.rotated(-2.5) * player_icon_size * 0.6
	
	var points = PackedVector2Array([
		center + forward,
		center + left,
		center + right
	])
	
	draw_colored_polygon(points, player_color)
	# Draw outline
	draw_polyline(points + PackedVector2Array([center + forward]), player_color.lightened(0.3), 1.0)


func _world_to_minimap(world_pos: Vector2, player_world_pos: Vector2, center: Vector2, scale_factor: float) -> Vector2:
	var relative = world_pos - player_world_pos
	return center + relative * scale_factor
