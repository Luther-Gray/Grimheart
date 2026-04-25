extends CharacterBody3D

@export var Attribute : Attributes
@export var Stat : Stats
@export var Vitals : Core

@onready var CameraRaycast: RayCast3D = $CameraPivot/CameraRaycast

#// Global Speed
var MoveSpeed : float
#// Tap vs Hold
var HoldTimer : float = 0.3
var TapTimer : float = 0.0
#// Ledge Grab
#// Parkour
#// State
var InputDir : Vector2 = Vector2.ZERO
var isUnsheathed : bool = false
var isMoving : bool = false
var isSprinting : bool = false
var isFalling : bool = false
var isHanging : bool = false
var isCrouched : bool = false

func _physics_process(delta: float) -> void:
	#// State Manager
	if not is_on_floor():
		isFalling = true
		velocity += get_gravity() * delta
	elif is_on_floor():
		isFalling = false
	if Input.is_action_pressed("MV_Sprint") and isMoving:
		isSprinting = true
		MoveSpeed = Stat.SprintSpeed
	else:
		isSprinting = false
		MoveSpeed = Stat.WalkSpeed

	InputDir = Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
	var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
	if Direction:
		velocity.x = Direction.x * MoveSpeed
		velocity.z = Direction.z * MoveSpeed
		isMoving = true
	else:
		velocity.x = move_toward(velocity.x, 0, MoveSpeed)
		velocity.z = move_toward(velocity.z, 0, MoveSpeed)
		isMoving = false
		
	move_and_slide()
