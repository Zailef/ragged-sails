extends CharacterBody2D

@export var move_speed = 50.0

func _physics_process(_delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_direction:
		velocity = input_direction * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed)

	move_and_slide()
