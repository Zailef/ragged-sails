## A secondary harpoon projectile spawned by the Dual Harpoons upgrade.
extends Node2D
class_name SecondaryHarpoon

var primary_harpoon: Harpoon
var target: Enemy
var target_marker: Marker2D
var is_flying: bool = false
var is_pinned: bool = false
var damage_timer: float = 0.0

var sprite: Sprite2D
var rope: Line2D


func setup(primary: Harpoon, new_target: Enemy) -> void:
	primary_harpoon = primary
	target = new_target
	target_marker = target.get_node_or_null("AnimatedSprite2D/TargetMarker")
	
	if not target_marker:
		queue_free()
		return
	
	# Create visual components
	_create_visuals()
	
	# Position at player and aim at target
	global_position = primary.get_player().global_position
	var to_target = (target_marker.global_position - global_position).normalized()
	rotation = to_target.angle()
	is_flying = true


func _create_visuals() -> void:
	# Create sprite (copy from primary)
	sprite = Sprite2D.new()
	sprite.texture = primary_harpoon.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("default", 0)
	sprite.scale = Vector2(0.5, 0.5)
	add_child(sprite)
	
	# Create rope
	rope = Line2D.new()
	rope.width = 1.0
	rope.default_color = primary_harpoon.rope.default_color
	rope.visible = false
	add_child(rope)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(primary_harpoon) or primary_harpoon.current_state != primary_harpoon.WeaponState.ACTIVE:
		queue_free()
		return
	
	if not is_instance_valid(target) or not is_instance_valid(target_marker):
		queue_free()
		return
	
	var flight_speed = primary_harpoon.flight_speed
	
	if is_flying:
		var marker_pos = target_marker.global_position
		var to_target = (marker_pos - global_position).normalized()
		global_position += to_target * flight_speed * delta
		rotation = to_target.angle()
		
		rope.visible = true
		_update_rope()
		
		if global_position.distance_to(marker_pos) < 10.0:
			is_flying = false
			is_pinned = true
			damage_timer = 0.0
	
	elif is_pinned:
		global_position = target_marker.global_position
		var to_harpoon = (global_position - primary_harpoon.get_player().global_position).normalized()
		rotation = to_harpoon.angle()
		
		_update_rope()
		_apply_damage(delta)


func _apply_damage(delta: float) -> void:
	damage_timer += delta
	if damage_timer >= primary_harpoon.damage_rate:
		var damage = primary_harpoon.get_effective_damage()
		target.take_damage(damage)
		primary_harpoon.notify_enemy_hit(target)
		damage_timer = 0.0


func _update_rope() -> void:
	var ship_pos = primary_harpoon.get_player().global_position
	var start = to_local(ship_pos)
	var end = Vector2.ZERO
	rope.points = [start, end]
