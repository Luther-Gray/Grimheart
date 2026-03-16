extends CharacterBody3D

@export var Setting : Settings
@onready var Head: Node3D = $Clyde/Player/bHips/bTorso/bNeck
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var isMouseCaptured = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SYS_Escape"):  # Esc to toggle mouse
		isMouseCaptured = !isMouseCaptured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if isMouseCaptured else Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
#/ Mouse Look
	if event is InputEventMouseMotion and isMouseCaptured:
# Left & Right Mouse Look
		rotate_y(deg_to_rad(-event.relative.x * Setting.MouseSensitivity))
# Up & Down Mouse Look
		Head.rotate_x(deg_to_rad(-event.relative.y * Setting.MouseSensitivity))
#Clamp how far up and down the player can look.
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var InputDir := Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
	var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
	if Direction:
		velocity.x = Direction.x * SPEED
		velocity.z = Direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
			## Camera Sway
	if InputDir.x > 0 :
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(-Setting.SwayAmount), Setting.SwaySpeed * delta)
	elif InputDir.x < 0 :
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(Setting.SwayAmount),Setting.SwaySpeed * delta)
	else:
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(0), Setting.SwaySpeed * delta)

	move_and_slide()
