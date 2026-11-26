extends CharacterBody3D

#//----Player.GD---
## Player.GD acts as a unified place to hold every flag, statistic and needed base physics. It also holds the basic movement of forwards, backwards, left & right. It is intentionally barebones. Every ability outside of this class is its own node.

@export var Attribute : Attributes
@export var Stat : Stats
@export var Vitals : Core
@export var Status : StatusEffects
@export var Settings : GameSettings

@onready var PlayerCollision: CollisionShape3D = $PlayerCollision
@onready var DEVDirection: Node3D = $DEV_DirectionPivot


#// Locomotion Tuning
var MoveSpeed : float
var Acceleration : float = 20.0
var Deceleration : float = 145.0
var AirControl : float = 0.25
var Influence : float
var MaxStepHeight : float = 0.4 ## Maximum Step Height
var SlopeSpeed : float = 1.0
var SlopeUpMult : float = 0.15
var SlopeDownMult : float = 0.15

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
var isGrabbing : bool = false

func _ready() -> void:
	MoveSpeed = Stat.WalkSpeed

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if !isHanging and !isClambering:
			velocity += get_gravity() * delta
	if !isHanging and !isClambering and !Status.Stunned:
		InputDir = Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
		var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
		### Momentum Stuff
		if is_on_floor():
			Influence = 1.0
		else:
			Influence = AirControl
		if Direction:
			_slope(Direction)
			var TargetSpeed = MoveSpeed * SlopeSpeed
			velocity.x = move_toward(velocity.x, Direction.x * TargetSpeed, Acceleration * Influence * delta)
			velocity.z = move_toward(velocity.z, Direction.z * TargetSpeed, Acceleration * Influence * delta)
			isMoving = true
		else:
			velocity.x = move_toward(velocity.x, 0, Deceleration * Influence * delta)
			velocity.z = move_toward(velocity.z, 0, Deceleration * Influence * delta)
			isMoving = false
	if !isHanging:
		move_and_slide()
	if isMoving: ## Dev Stuff
		DEVDirection.rotation.y = atan2(-InputDir.x, -InputDir.y)
		
func _slope(Direction : Vector3): ## Adjusts its value based on the detected slope angle of terrain.
	SlopeSpeed = 1.0
	if !is_on_floor() or Direction == Vector3.ZERO:
		return
	var FloorNormal = get_floor_normal()
	var SlopeDirection = Vector3(FloorNormal.x, 0.0, FloorNormal.z)
	if SlopeDirection.is_zero_approx():
		return
	SlopeDirection = SlopeDirection.normalized()
	var SlopeSeverity = clamp(get_floor_angle() / floor_max_angle, 0.0, 1.0)
	var SlopeAmount = Direction.dot(SlopeDirection)
	if SlopeAmount < 0.0:
		SlopeSpeed =  1.0 + SlopeAmount * SlopeSeverity * SlopeUpMult
	else:
		SlopeSpeed = 1.0 + SlopeAmount * SlopeSeverity * SlopeDownMult
