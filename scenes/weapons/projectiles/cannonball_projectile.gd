## A cannonball projectile that travels toward a target and splashes on impact/max distance.
extends Projectile
class_name CannonballProjectile

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea
@onready var splash_sound: AudioStreamPlayer2D = $SplashSound

var _is_splashing: bool = false


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	damage_area.area_entered.connect(_on_area_entered)
	animated_sprite.play("moving")


func _physics_process(delta: float) -> void:
	if _is_splashing:
		return
	
	super(delta)
	
	# Start splash animation at half distance
	if max_distance > 0 and _distance_traveled >= (max_distance / 2.0):
		_start_splash()


func _on_max_distance_reached() -> void:
	# Don't destroy immediately - play splash first
	if not _is_splashing:
		_start_splash()


func _start_splash() -> void:
	if _is_splashing:
		return
	
	_is_splashing = true
	animated_sprite.play("splash")


func _on_animation_finished() -> void:
	if animated_sprite.animation == "splash":
		splash_sound.play()
		# Wait for sound to play a bit before destroying
		await get_tree().create_timer(0.1).timeout
		destroy()


func _on_area_entered(area: Area2D) -> void:
	var owner_node = area.get_owner()
	if owner_node is Enemy:
		_on_enemy_hit(owner_node)
