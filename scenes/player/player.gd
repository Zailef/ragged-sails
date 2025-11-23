extends CharacterBody2D
class_name Player

@export_group("player stats")
@export var move_speed = 50.0
@export var max_health = 100
@export var level_progress: PlayerLevelProgress

@export_group("damage feedback")
@export var damage_flash_duration = 0.5
@export var damage_flash_strength = 0.5

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shader_material: ShaderMaterial = animated_sprite.material as ShaderMaterial
@onready var health_bar: ProgressBar = $HealthBar

var is_dead: bool = false

var current_health: int = max_health:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_bar.value = current_health

func _physics_process(_delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_direction:
		velocity = input_direction * move_speed
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Move/blend_position", input_direction)
		animation_state.travel("Move")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed)
		animation_state.travel("Idle")

	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount

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

func add_experience(amount: int) -> void:
	level_progress.add_experience(amount)
	print("Gained %d experience points." % amount)
