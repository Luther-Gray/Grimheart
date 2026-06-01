extends CharacterBody3D

#----Player.GD---
## Player.GD acts as a unified place to hold every flag, statistic and needed base physic. It also holds the basic movement of forwards, backwards, left & right. It is intentionally barebones. Every ability outside of this class is its own node.

@export var Attribute : Attributes
@export var Stat : Stats
@export var Vitals : Core
@export var Status : StatusEffects
@export var Settings : GameSettings

@onready var PlayerCollision: CollisionShape3D = $PlayerCollision

#// Global Speed - This is modified by Stat
var MoveSpeed : float
var Acceleration : float = 20.0
var Deceleration : float = 45.0
var AirControl : float = 0.25
var Influence : float
#// State Flags
var InputDir : Vector2 = Vector2.ZERO
var isUnsheathed : bool = false
var isMoving : bool = false
var isSprinting : bool = false
var isJumping : bool = false
var isFalling : bool = false
var isHanging : bool = false
var isClambering : bool = false
var isVaulting : bool = false
var isCrouched : bool = false
var isSliding : bool = false
var isWallRunning : bool = false

func _ready() -> void:
	MoveSpeed = Stat.WalkSpeed

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if !isHanging and !isClambering and !isWallRunning:
			velocity += get_gravity() * delta
	if !isHanging and !isVaulting and !isClambering and !Status.Stunned:
		InputDir = Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
		var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
		### Momentum Stuff
		if is_on_floor():
			Influence = 1.0
		else:
			Influence = AirControl

		if Direction:
			velocity.x = move_toward(velocity.x, Direction.x * MoveSpeed, Acceleration * Influence * delta)
			velocity.z = move_toward(velocity.z, Direction.z * MoveSpeed, Acceleration * Influence * delta)
			isMoving = true
		else:
			velocity.x = move_toward(velocity.x, 0, Deceleration * Influence * delta)
			velocity.z = move_toward(velocity.z, 0, Deceleration * Influence * delta)
			isMoving = false
		
	move_and_slide()
