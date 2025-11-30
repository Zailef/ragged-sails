extends Weapon
class_name Cannonball

# TODO: stat for max enemy penetration

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea
@onready var splash_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var cannon_fire_sound: AudioStreamPlayer = $CannonFireSound

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var max_distance: float = 150.0

func _ready() -> void:
	super ()
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return

	if distance_traveled >= (max_distance / 2) and animated_sprite.animation != "splash":
		animated_sprite.play("splash")

	if distance_traveled >= max_distance:
		return

	global_position += direction * weapon_stats.speed * delta
	distance_traveled += weapon_stats.speed * delta

func _fire_weapon() -> void:
	var context: TargetingContext = TargetingContext.new()
	context.user = get_player()
	context.enemies = get_tree().get_nodes_in_group("enemies")
	context.weapon_stats = weapon_stats

	var result: TargetingResult = targeting_strategy.get_target(context)

	if result.has_target():
		# Reset position to player before firing
		global_position = get_player().global_position
		distance_traveled = 0.0
		direction = Vector2(result.target.global_position - global_position).normalized()
	else:
		# No target, so reset direction to prevent firing
		direction = Vector2.ZERO

func _reset_weapon() -> void:
	damage_area.monitoring = false
	global_position = get_player().global_position
	direction = Vector2.ZERO
	distance_traveled = 0.0
	animated_sprite.animation = "moving"
	hide()

func _on_animation_finished() -> void:
	if animated_sprite.animation == "splash":
		splash_sound.play()
		end_active_phase()

func _activate() -> void:
	# Only activate if we have a valid direction (i.e., a target was found)
	if direction == Vector2.ZERO:
		end_active_phase()
		return

	damage_area.monitoring = true
	animated_sprite.play("moving")
	cannon_fire_sound.play()
	show()
