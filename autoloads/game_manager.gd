extends Node

const URCHIN_SCENE: PackedScene = preload("res://scenes/enemies/urchin.tscn")

var session_enemies_defeated: int = 0

func _ready() -> void:
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)
	get_tree().scene_changed.connect(_on_scene_changed)

func _on_enemy_defeated() -> void:
	session_enemies_defeated += 1

func spawn_urchin(position: Vector2) -> void:
	var urchin_instance: Enemy = URCHIN_SCENE.instantiate() as Enemy
	urchin_instance.global_position = position
	get_tree().get_current_scene().get_node("Enemies").add_child(urchin_instance)

func _choose_enemy_spawn_position() -> Vector2:
	var viewport = get_viewport()
	var viewport_rect = viewport.get_visible_rect()
	var camera = viewport.get_camera_2d()

	if not camera:
		return Vector2.ZERO

	var camera_pos = camera.get_screen_center_position()
	var screen_size = viewport_rect.size

	var spawn_margin = 50.0
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO

	match edge:
		0: # Top
			spawn_pos.x = camera_pos.x + randf_range(-screen_size.x / 2, screen_size.x / 2)
			spawn_pos.y = camera_pos.y - screen_size.y / 2 - spawn_margin
		1: # Right
			spawn_pos.x = camera_pos.x + screen_size.x / 2 + spawn_margin
			spawn_pos.y = camera_pos.y + randf_range(-screen_size.y / 2, screen_size.y / 2)
		2: # Bottom
			spawn_pos.x = camera_pos.x + randf_range(-screen_size.x / 2, screen_size.x / 2)
			spawn_pos.y = camera_pos.y + screen_size.y / 2 + spawn_margin
		3: # Left
			spawn_pos.x = camera_pos.x - screen_size.x / 2 - spawn_margin
			spawn_pos.y = camera_pos.y + randf_range(-screen_size.y / 2, screen_size.y / 2)

	return spawn_pos

func _spawn_random_enemy() -> void:
	var spawn_position = _choose_enemy_spawn_position()
	spawn_urchin(spawn_position)
	get_tree().create_timer(1.0).timeout.connect(_spawn_random_enemy, CONNECT_ONE_SHOT)

func _on_scene_changed() -> void:
	if get_tree().get_current_scene().name != "Sandbox":
		return

	get_tree().create_timer(1.0).timeout.connect(_spawn_random_enemy, CONNECT_ONE_SHOT)
