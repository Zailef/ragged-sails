## Anchor weapon that spawns orbiting anchors around the player.
extends BaseWeapon
class_name Anchor

const AnchorProjectileScene = preload("res://scenes/weapons/projectiles/anchor_projectile.tscn")

@export var orbit_radius: float = 48.0

var anchors: Array[AnchorProjectile] = []


func _fire_weapon() -> void:
	# Default: spawn one anchor at angle 0
	spawn_anchor(0.0)


func _activate() -> void:
	for anchor in anchors:
		if is_instance_valid(anchor):
			anchor.activate()


func _reset_weapon() -> void:
	for anchor in anchors:
		if is_instance_valid(anchor):
			anchor.deactivate()
			anchor.queue_free()
	anchors.clear()


func spawn_anchor(start_angle: float) -> AnchorProjectile:
	var anchor: AnchorProjectile = AnchorProjectileScene.instantiate()
	get_tree().current_scene.add_child(anchor)
	anchor.setup_anchor(get_player(), weapon_stats.damage, orbit_radius, weapon_stats.speed, start_angle, self)
	anchors.append(anchor)
	return anchor


func get_anchor_count() -> int:
	return anchors.size()


## Adds a new anchor and redistributes all anchors evenly around the circle.
func add_anchor_and_redistribute() -> void:
	# Spawn new anchor (angle doesn't matter, we'll fix it)
	spawn_anchor(0.0)
	redistribute_anchors()


## Redistributes all anchors evenly around the circle.
func redistribute_anchors() -> void:
	var count = anchors.size()
	if count == 0:
		return
	
	var angle_step = TAU / count
	for i in range(count):
		if is_instance_valid(anchors[i]):
			anchors[i].orbit_angle = i * angle_step
