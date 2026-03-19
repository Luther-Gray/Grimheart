extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 20
var InputDir : Vector2 = Vector2.ZERO
var isMoving = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("MV_Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	InputDir = Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
	var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
	if Direction:
		velocity.x = Direction.x * SPEED
		velocity.z = Direction.z * SPEED
		isMoving = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		isMoving = false
		
	move_and_slide()
