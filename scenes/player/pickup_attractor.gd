extends Area2D
class_name PickupAttractor

## Attracts nearby pickups toward the player.
## Add this as a child of the player with a CollisionShape2D to define the attraction radius.

@export var attraction_radius: float = 100.0:
	set(value):
		attraction_radius = value
		_update_collision_shape()


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_update_collision_shape()


func _update_collision_shape() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = attraction_radius


func _on_area_entered(area: Area2D) -> void:
	# Check if the area's parent is a Pickup
	var pickup := area.get_parent() as Pickup
	if pickup:
		pickup.start_attraction(get_owner())


func _on_area_exited(area: Area2D) -> void:
	# Check if the area's parent is a Pickup
	var pickup := area.get_parent() as Pickup
	if pickup:
		pickup.stop_attraction()
