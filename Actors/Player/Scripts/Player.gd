extends CharacterBody3D

#----Player.GD---
## Player.GD acts as a unified place to hold every flag, statistic and needed base physic. It also holds the basic movement of forwards, backwards, left & right. It is intentionally barebones. Every ability outside of this class is its own node.

@export var Attribute : Attributes
@export var Stat : Stats
@export var Vitals : Core
@export var Settings : GameSettings

@onready var PlayerCollision: CollisionShape3D = $PlayerCollision

#// Global Speed - This is modified by Stat
var MoveSpeed : float
#// State Flags
var InputDir : Vector2 = Vector2.ZERO
var isUnsheathed : bool = false
var isMoving : bool = false
var isSprinting : bool = false
var isJumping : bool = false
var isFalling : bool = false
var isHanging : bool = false
var isCrouched : bool = false
var isWallRunning : bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if !isHanging:
			velocity += get_gravity() * delta
	if !isHanging:
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
