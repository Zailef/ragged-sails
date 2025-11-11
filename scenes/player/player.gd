extends CharacterBody2D

@export var move_speed = 50.0
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

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
