extends Resource
class_name LootTable

const EXP_PICKUP: PackedScene = preload("res://scenes/pickups/exp_pickup.tscn")
const LIFE_RING_PICKUP: PackedScene = preload("res://scenes/pickups/life_ring_pickup.tscn")

@export var table: Dictionary[PackedScene, float] = {
    EXP_PICKUP: 1.0,
    LIFE_RING_PICKUP: 0.05,
}
