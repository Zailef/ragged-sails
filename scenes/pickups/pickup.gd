extends Node2D
class_name Pickup

@export var effect: PickupEffect

func _on_pickup_area_area_entered(area: Area2D) -> void:
	var player = area.get_owner()
	effect.apply_effect(self, player)
	queue_free()
