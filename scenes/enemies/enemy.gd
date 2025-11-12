extends CharacterBody2D
class_name Enemy

var player: Player = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var stats: EnemyStats

var has_directional_animations: bool = false
var is_player_in_hurt_area: bool = false
var damage_rate_timer: float = 0.0

func _ready() -> void:
	_set_has_directional_animations()
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	if not is_player_in_hurt_area:
		velocity = direction * stats.move_speed
	else:
		velocity = Vector2.ZERO

	_handle_animations(direction)
	_handle_damage(delta)

	move_and_slide()

func _set_has_directional_animations() -> void:
	var frames = sprite.sprite_frames
	has_directional_animations = (
		frames.has_animation("move_up") and
		frames.has_animation("move_down") and
		frames.has_animation("move_left") and
		frames.has_animation("move_right"))

func _handle_animations(direction: Vector2) -> void:
	var new_animation: String
	
	if has_directional_animations:
		if abs(direction.x) > abs(direction.y):
			new_animation = "move_right" if direction.x > 0 else "move_left"
		else:
			new_animation = "move_down" if direction.y > 0 else "move_up"
	else:
		new_animation = "move"
	
	if sprite.animation != new_animation:
		sprite.animation = new_animation

func _on_hit_area_area_entered(_area: Area2D) -> void:
	is_player_in_hurt_area = true

func _on_hit_area_area_exited(_area: Area2D) -> void:
	is_player_in_hurt_area = false
	damage_rate_timer = 0.0

func _handle_damage(delta: float) -> void:
	if not is_player_in_hurt_area:
		return

	damage_rate_timer += delta
	if damage_rate_timer >= stats.damage_rate:
		player.take_damage(stats.damage)
		damage_rate_timer = 0.0
