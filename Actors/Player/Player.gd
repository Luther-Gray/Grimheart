extends CharacterBody3D
class_name Player

#// Resources
@export var CoreValues : Core
@export var Attribute : Attributes
@export var Skill : Skills
@export var Affinity : Affinities
@export var Stat : Stats
@export var Status : StatusEffects
@export var Setting : Settings

#//Imported
@onready var Head: Node3D = $Head
@onready var Camera: Camera3D = $Head/PlayerCamera
@onready var CinCamera: Camera3D = $CinemaArm/CinemaCamera
@onready var Collision: CollisionShape3D = $PlayerCollision
@onready var CameraRay: RayCast3D = $Head/PlayerCamera/CameraRay
@onready var Body: Node3D = $Body
@onready var LedgeRay: RayCast3D = $LedgeRayCast
@onready var ClamberRay: ShapeCast3D = $ClamberShapeCast
@onready var CrouchRay: RayCast3D = $Head/CrouchRayCast
@onready var DebugOverlay: Control = $Debug
#// Extra Imports for WallRun. Don't know if I'll use it.
@onready var CheckRight: RayCast3D = $CheckRight
@onready var CheckLeft: RayCast3D = $CheckLeft

# No I'm not using a state machine. Not even an enum machine. Go to hell.

#// Movement
var BaseSpeed : int = 8
var CurrentSpeed : int = BaseSpeed
var ACCEL = 50.0
var AirControl : int = 100
var Direction := Vector3.ZERO
#// Sprint
var isSprinting : bool
var SprintSpeed : int = BaseSpeed * 2
#// Dodge
var DodgeTimer : float = 0.0
var DodgeDuration : float = 0.10
#// Jump
var JUMP_VELOCITY : float :
	get:
		return (Attribute.Alacrity / 16.0) + Stat.JumpStrength
var CoyoteTimer : float = 0.0
var CoyoteDuration : float = 0.15 # 9 Frames or so of leeway?
#// Crouch
var isCrouching : bool = false
var InitCameraHeight = 1.7
var InitCollisionHeight : float = 2.0
var InitCollisionPosition : float = 1.0
var CrouchCamera : float = 0.4
var CrouchHeight : float = 1.5
var CrouchPosition: float = 0.75
var CrouchSpeed : int = 5
#// Slide
var SlopeSpeed : int = 10
var SlopeMaxSpeed : int = 50
var  Friction : int = 60
var isSliding : bool = false
var SlideTimer : float = 0.0
var MaxSlideTime : float = 0.8

#// State
var isMouseCaptured : bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	#/ Mouse Escape/ Mouse Lock
	if event.is_action_pressed("SYS_Escape"):
		isMouseCaptured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("ATK_Right"):
		if !isMouseCaptured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			isMouseCaptured = true

func _input(event: InputEvent) -> void:
#/ Mouse Look
	if event is InputEventMouseMotion and isMouseCaptured:
# Left & Right Mouse Look
		rotate_y(deg_to_rad(-event.relative.x * Setting.MouseSensitivity))
# Up & Down Mouse Look
		Head.rotate_x(deg_to_rad(-event.relative.y * Setting.MouseSensitivity))
#Clamp how far up and down the player can look.
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _process(_delta: float) -> void:
		var DebugState = {
		"Position": self.global_position,
		"Speed": "%.1f m/s" % velocity.length(),
		"Jumping": !is_on_floor(),
		"Crouching": isCrouching,
		"Sprinting": isSprinting,
		"Sliding": isSliding
		}
		var Order = 1
		for KEY in DebugState:
			DebugOverlay._add_debug(KEY, DebugState[KEY],Order)
			Order += 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("SYS_Perspective"):
		_perspective()

## Add the gravity.
	velocity += get_gravity() * delta
## Handle jump/vault.
	if Input.is_action_just_pressed("MV_Jump") and CoyoteTimer > 0:
		if not _handle_vaulting():
			_handle_jump()
			CoyoteTimer = 0
	elif Input.is_action_just_released("MV_Jump") and velocity.y > 0:
		velocity.y *= 0.5
## Handle Slide
	if Input.is_action_just_pressed("MV_Crouch") and is_on_floor() and !isCrouching:
		_handle_slide(delta)

## Input Vector Detection and Mapping
	var InputDir = Input.get_vector("MV_Left", "MV_Right", "MV_Forward", "MV_Backward")
	Direction = (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
## Movement!!!
	if is_on_floor():
		CoyoteTimer = CoyoteDuration
		if !isSliding: # Normal Movement behavior.
			var TargetVelocity = Direction * CurrentSpeed
			var AccelRate: float
			if Direction.length() > 0:
				AccelRate = ACCEL
			else:
				AccelRate = Friction
			velocity.x =move_toward(velocity.x, TargetVelocity.x, AccelRate * delta)
			velocity.z =move_toward(velocity.z, TargetVelocity.z, AccelRate * delta)
		else: # To prevent jumps from slowing you down.
			velocity.x =move_toward(velocity.x, 0 , Friction * delta)
			velocity.z =move_toward(velocity.z,0 , Friction * delta)
	else: # Allow Air Control
		CoyoteTimer -= delta
		if Direction.length() > 0:
			var Alignment = Direction.dot(velocity.normalized())
			var WishSpeed = Vector2(velocity.x, velocity.z).length()
			var TargetSpeed: float
			if Alignment > 0.5:
				TargetSpeed = max(CurrentSpeed, WishSpeed)
			else:
				TargetSpeed = CurrentSpeed
			var TargetVelocity = Direction * TargetSpeed
			velocity.x =move_toward(velocity.x, TargetVelocity.x, AirControl * delta)
			velocity.z =move_toward(velocity.z, TargetVelocity.z, AirControl * delta)
## Sprinting
	if Input.is_action_just_pressed("MV_Sprint") and InputDir != Vector2.ZERO and  is_on_floor():
		if !isCrouching and !isSliding:
			isSprinting = true
	if InputDir == Vector2.ZERO or isCrouching or isSliding:
		isSprinting = false
	if isSprinting:
		CurrentSpeed = SprintSpeed
	else:
		CurrentSpeed = BaseSpeed
## Crouching
	if is_on_floor() and !isSliding:
		var CeilingBlocked : bool = CrouchRay.is_colliding()
		if Input.is_action_just_pressed("MV_Crouch") or CeilingBlocked:
			if !isCrouching:
				_handle_crouch()
			else:
				if isCrouching and !CrouchRay.is_colliding():
					_stop_crouch()
## Sliding (Can slide UP slopes FOREVER. Keep it in because it's fun lol)
	if isSliding:
		if is_on_floor():
			# Stick to Floor while sliding
			var FloorNormal = get_floor_normal()
			var NewY = FloorNormal
			var NewX = NewY.cross(global_transform.basis.z).normalized()
			var NewZ = NewX.cross(NewY).normalized()
			Body.global_basis = Basis(NewX, NewY, NewZ)
			velocity.y = velocity.slide(FloorNormal).y
			# Acceleration
			if FloorNormal.dot(Vector3.UP) < 0.95:
				SlideTimer = MaxSlideTime
				velocity.x += FloorNormal.x * SlopeSpeed * 3 * delta # *3 is a magic number. I don't know what to plug in there, but *3 feels right.
				velocity.z +=  FloorNormal.z * SlopeSpeed * 3 * delta
				# Speed Cap
				var HorizontalVelocity = Vector2(velocity.x, velocity.z)
				if HorizontalVelocity.length() > SlopeMaxSpeed:
					HorizontalVelocity = HorizontalVelocity.limit_length(SlopeMaxSpeed)
					velocity.x = HorizontalVelocity.x
					velocity.z = HorizontalVelocity.y
			else: SlideTimer -= delta
		if SlideTimer <= 0 or Input.is_action_just_pressed("MV_Jump"):
			var SlideJump = Input.is_action_just_pressed("MV_Jump")
			_stop_slide()
			Body.transform.basis = Basis.IDENTITY
			if SlideJump:
				velocity.y = JUMP_VELOCITY

	move_and_slide()

## Camera Sway
	if InputDir.x > 0 :
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(-Setting.SwayAmount), Setting.SwaySpeed * delta)
	elif InputDir.x < 0 :
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(Setting.SwayAmount),Setting.SwaySpeed * delta)
	else:
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(0), Setting.SwaySpeed * delta)

#// Functions
## Jumping
func _handle_jump():
	velocity.y = JUMP_VELOCITY
## Vaulting. Technically, the vault can still happen if you angle your head away from the wall. Keep it because it's fun.
func _handle_vaulting() -> bool:
	if ClamberRay.is_colliding():
		var WallNormal = ClamberRay.get_collision_normal(0)
		if WallNormal.y > 0.5: # You shouldn't be able to vault over a slope.
			return false
		if !LedgeRay.is_colliding():
			global_position += -WallNormal * 2
			velocity = (-WallNormal * CurrentSpeed) + (Vector3.UP * JUMP_VELOCITY * 0.9)
			return true
	return false

## Crouching
func _handle_crouch():
	isCrouching = true
	CurrentSpeed = CrouchSpeed
	_help_height(CrouchHeight, CrouchPosition, CrouchCamera)

## Stop Crouching
func _stop_crouch():
	if CrouchRay.is_colliding():
		isCrouching = true
		CurrentSpeed = CrouchSpeed
		_help_height(CrouchHeight, CrouchPosition, CrouchCamera)
	else:
		isCrouching = false
		CurrentSpeed = BaseSpeed
		_help_height(InitCollisionHeight, InitCollisionPosition,InitCameraHeight)

## Sliding Half this is boilerplate to move your Head and Collision.
func _handle_slide(delta):
	if !isSliding and Direction.length() > 0:
		isSliding = true
		Friction = 10
		SlideTimer = MaxSlideTime
		velocity += Direction * SlopeSpeed
		Head.rotation.z = lerp_angle(Head.rotation.z, deg_to_rad(Setting.SwayAmount),Setting.SwaySpeed * delta)
		_help_height(CrouchHeight, CrouchPosition, CrouchCamera)

## Stopping the slide  ALL of this is boilerplate to move your Head and Collision.
func _stop_slide():
	isSliding = false
	Friction = 60
	var CeilingBlocked : bool = CrouchRay.is_colliding()
	if CeilingBlocked:
		_help_height(CrouchHeight, CrouchPosition, CrouchCamera)
		isCrouching = true
	else:
		isCrouching = false
		_help_height(InitCollisionHeight, InitCollisionPosition,InitCameraHeight)

func _help_height(height: float, pos: float, cam: float):
	Collision.shape.height = height
	Collision.position.y = pos
	Head.position.y = cam

func _perspective():
		var isFPS = Camera.current
		var isTPS = CinCamera.current
		Camera.current = !isFPS
		CinCamera.current = !isTPS
