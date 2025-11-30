extends CharacterBody2D
class_name Player

@export_group("Debug")
@export var is_immortal: bool = false
@export var debug_mobile_controls: bool = false

@export_group("Player Stats")
@export var move_speed = 50.0
@export var max_health = 100
@export var level_progress: PlayerLevelProgress

@export_group("Damage Feedback")
@export var damage_flash_duration = 0.5
@export var damage_flash_strength = 0.5

@export_group("Collision")
@export var horizontal_collision_offset: Vector2 = Vector2(0, 10)

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shader_material: ShaderMaterial = animated_sprite.material as ShaderMaterial
@onready var health_bar: ProgressBar = $HealthBar
@onready var hurt_sound: AudioStreamPlayer = %DamageSound
@onready var level_up_sound: AudioStreamPlayer = %LevelUpSound
@onready var virtual_joystick: Node2D = %VirtualJoystick
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_collision_shape: CollisionShape2D = $HurtArea/CollisionShape2D

var is_dead: bool = false
var is_mobile: bool = false
var _facing_direction: Vector2 = Vector2.DOWN

var current_health: int = max_health:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_bar.value = current_health

func _ready() -> void:
	SignalManager.exp_gained.connect(_on_exp_gained)
	SignalManager.player_levelled_up.connect(_on_player_levelled_up)
	_setup_mobile_controls()

func _setup_mobile_controls() -> void:
	is_mobile = OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web_android") or OS.has_feature("web_ios") or debug_mobile_controls
	virtual_joystick.visible = is_mobile

func _physics_process(_delta: float) -> void:
	var input_direction = _get_input_direction()

	if input_direction:
		velocity = input_direction * move_speed
		_facing_direction = input_direction.normalized()
		_update_collision_rotation()
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Move/blend_position", input_direction)
		animation_state.travel("Move")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed)
		animation_state.travel("Idle")

	move_and_slide()

func _update_collision_rotation() -> void:
	# Rotate capsule to align with ship facing direction
	# The capsule's default orientation is vertical, so we rotate based on facing
	var target_rotation = _facing_direction.angle() + PI / 2.0
	collision_shape.rotation = target_rotation
	hurt_collision_shape.rotation = target_rotation
	
	# Apply offset when facing horizontally (left/right)
	var is_horizontal = abs(_facing_direction.x) > abs(_facing_direction.y)
	if is_horizontal:
		collision_shape.position = horizontal_collision_offset
		hurt_collision_shape.position = horizontal_collision_offset
	else:
		collision_shape.position = Vector2.ZERO
		hurt_collision_shape.position = Vector2.ZERO

func _get_input_direction() -> Vector2:
	# Use virtual joystick on mobile, keyboard/gamepad otherwise
	if is_mobile and virtual_joystick:
		return virtual_joystick.position_vector
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func take_damage(amount: int) -> void:
	if is_immortal or is_dead:
		return

	current_health -= amount
	hurt_sound.play()

	damage_shader_material.set_shader_parameter("flash_strength", damage_flash_strength)
	var tween := create_tween()
	tween.tween_property(damage_shader_material, "shader_parameter/flash_strength", 0.0, damage_flash_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if current_health <= 0 and not is_dead:
		_die()

func _die() -> void:
	# TODO: proper death handling (animations, sound, transition to game over, etc.)
	is_dead = true
	print("Player has died.")
	set_physics_process(false)
	set_process(false)
	hide()
	get_tree().create_timer(3.0).timeout.connect(func(): get_tree().reload_current_scene.call_deferred())

func _on_exp_gained(amount: int) -> void:
	level_progress.add_experience(amount)

func _on_player_levelled_up(new_level: int, exp_to_next_level: int) -> void:
	level_up_sound.play()
