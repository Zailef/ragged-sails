extends Resource
class_name MapBoundaryConfig

## Configuration for map boundary zones.

@export_group("Safe Zone")
## The rectangular safe play area (in world coordinates)
@export var safe_zone: Rect2 = Rect2(-500, -500, 1000, 1000)

@export_group("Warning Zone")
## Width of the warning zone outside the safe zone (in pixels)
@export var warning_zone_width: float = 100.0

## Speed multiplier when in warning zone (0.5 = half speed)
@export var warning_speed_multiplier: float = 0.5

## Tint color for warning zone (used by visual feedback)
@export var warning_tint_color: Color = Color(0.3, 0.2, 0.1, 0.4)

@export_group("Danger Zone")
## Width of the danger zone outside the warning zone (in pixels)
## Beyond this is instant death
@export var danger_zone_width: float = 100.0

## Damage per second in the danger zone
@export var danger_damage_per_second: float = 25.0

## Speed multiplier in danger zone
@export var danger_speed_multiplier: float = 0.25

## Tint color for danger zone
@export var danger_tint_color: Color = Color(0.5, 0.0, 0.0, 0.6)

@export_group("Death Zone")
## Instant kill if player reaches this zone
@export var instant_death_enabled: bool = true

## Get the warning zone rect (safe zone expanded by warning width)
func get_warning_zone() -> Rect2:
	return safe_zone.grow(warning_zone_width)

## Get the danger zone rect (warning zone expanded by danger width)
func get_danger_zone() -> Rect2:
	return get_warning_zone().grow(danger_zone_width)

## Returns what zone the position is in: "safe", "warning", "danger", or "death"
func get_zone_at_position(pos: Vector2) -> String:
	if safe_zone.has_point(pos):
		return "safe"
	elif get_warning_zone().has_point(pos):
		return "warning"
	elif get_danger_zone().has_point(pos):
		return "danger"
	else:
		return "death"

## Returns how far into a danger zone the position is (0.0 = edge, 1.0 = deep)
func get_zone_depth(pos: Vector2) -> float:
	if safe_zone.has_point(pos):
		return 0.0
	
	# Calculate distance from safe zone edge
	var clamped = Vector2(
		clampf(pos.x, safe_zone.position.x, safe_zone.end.x),
		clampf(pos.y, safe_zone.position.y, safe_zone.end.y)
	)
	var distance_from_safe = pos.distance_to(clamped)
	
	var total_danger_width = warning_zone_width + danger_zone_width
	return clampf(distance_from_safe / total_danger_width, 0.0, 1.0)
