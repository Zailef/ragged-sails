extends DropStrategy
class_name DropStrategyDefault

const EXP_PICKUP_SCENE = preload("res://scenes/pickups/exp_pickup.tscn")

func perform_drops(context: DropStrategyContext) -> void:
	var enemy = context.enemy

	if enemy.loot_table == null:
		push_warning("Enemy %s has no loot table assigned!" % enemy.name)
		return
	
	var dropped_exp = false
	
	for pickup_scene in enemy.loot_table.table.keys():
		var drop_chance = enemy.loot_table.table[pickup_scene]
		if randf() < drop_chance:
			var pickup_instance = pickup_scene.instantiate() as Pickup
			pickup_instance.global_position = enemy.global_position
			enemy.get_tree().current_scene.add_child.call_deferred(pickup_instance)
			
			if pickup_scene == EXP_PICKUP_SCENE:
				dropped_exp = true
	
	if not dropped_exp:
		var exp_pickup = EXP_PICKUP_SCENE.instantiate() as Pickup
		exp_pickup.global_position = enemy.global_position
		enemy.get_tree().current_scene.add_child.call_deferred(exp_pickup)
