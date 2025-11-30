extends DropStrategy
class_name DropStrategyBoss

## Drop strategy for bosses - always drops a chest for weapon upgrades.

const CHEST_PICKUP_SCENE = preload("res://scenes/pickups/chest_pickup.tscn")

func perform_drops(context: DropStrategyContext) -> void:
	var enemy = context.enemy
	
	# Bosses always drop a chest
	var chest = CHEST_PICKUP_SCENE.instantiate() as Pickup
	chest.global_position = enemy.global_position
	enemy.get_tree().current_scene.add_child.call_deferred(chest)
