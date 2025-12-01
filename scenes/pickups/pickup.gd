extends Node2D
class_name Pickup

@export var effect: PickupEffect

## Whether this pickup can be attracted to the player
@export var attractable: bool = false

## Speed at which the pickup moves toward the player when attracted
@export var attraction_speed: float = 120.0

## Acceleration applied each frame when attracted (creates satisfying ramp-up)
@export var attraction_acceleration: float = 150.0

var _attracted_to: Node2D = null
var _current_speed: float = 0.0


func _ready() -> void:
	if not effect:
		push_error("Pickup %s has no effect assigned!" % self.name)


func _physics_process(delta: float) -> void:
	if _attracted_to and is_instance_valid(_attracted_to):
		# Accelerate toward max speed
		_current_speed = minf(_current_speed + attraction_acceleration * delta, attraction_speed)

		# Move toward player
		var direction := global_position.direction_to(_attracted_to.global_position)
		global_position += direction * _current_speed * delta


func start_attraction(target: Node2D) -> void:
	if attractable and _attracted_to == null:
		_attracted_to = target
		_current_speed = 0.0


func stop_attraction() -> void:
	_attracted_to = null
	_current_speed = 0.0


func _on_pickup_area_area_entered(area: Area2D) -> void:
	var owner_node = area.get_owner()
	if owner_node is Player:
		var player: Player = owner_node
		effect.apply_effect(self, player)
		queue_free()
