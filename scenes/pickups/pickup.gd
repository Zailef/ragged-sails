extends Node2D
class_name Pickup

@export var effect: PickupEffect

func _ready() -> void:
	if not effect:
		push_error("Pickup %s has no effect assigned!" % self.name)

func _on_pickup_area_area_entered(area: Area2D) -> void:
	var owner_node = area.get_owner()
	if owner_node is Player:
		var player: Player = owner_node
		effect.apply_effect(self, player)
		queue_free()
