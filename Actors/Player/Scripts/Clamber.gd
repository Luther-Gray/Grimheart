@icon("res://addons/IconGodotNode/node_3D/icon_ledge.png")
extends Node3D

# Bro I'm SOOOOO Sorry this shit is so complex. 28 different fucking probes just to tell me "Hey man, can I jump this without falling through the world?" But what else am I gonna do? Math?! 

@export var Source: CharacterBody3D
@export var Crouch: Node3D
@export var GrabLedgeSound : AudioStream
@export var ClamberSound : AudioStream
@export var VaultSound : AudioStream
@export var AudioPlayer : AudioStreamPlayer3D
@export var ClamberCast: ShapeCast3D
@export var ClamberProbeCeiling: RayCast3D
@export var ClamberProbeHeight: RayCast3D
@export var VaultProbeDepth : RayCast3D ## Checks how "Deep" something is. If this hits something, we likely should NOT be vaulting.
@export var CrouchProbe: RayCast3D

@export_category("IK Things")
#// IK Locations
@export var IK_ArmL: TwoBoneIK3D
@export var IK_ArmR: TwoBoneIK3D
@export var HandTargetL: Marker3D
@export var HandTargetR: Marker3D

@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var CameraPivot: Node3D = $"../PlayerCollision/CameraPivot"
@onready var Jump : Node3D = $"../Jump"
@onready var DEV_Target: MeshInstance3D = $"../../DEV_Target"

@export_category("Ledge Tuning")
@export_range(1.0, 3.0, 0.1) var LedgeYOffset : float = 1.4
@export_range(-1.0, 1.0, 0.1) var LedgeZOffset : float = -0.75

@export_category("Clamber Tuning")
@export var ClamberForce : float = 2.0 ## Substantially lower than the vault.
@export var ClamberForwardBoost : float = 2.05 
@export var ClamberHeightBoost : float = 0.5
@export var ClamberCollisionHeight : float = 0.7 ## How Tall is the player when clambering
@export var ClamberCrouchF : float = 1.0
@export var ClamberCrouchBoost : float = 2.05
@export var ClamberCrouchHeight : float = 0.95

@export_category("Vault Tuning")
@export var VaultForce : float = 8.5
@export var VaultForwardBoost : float = 0.3
@export var CollisionInitHeight : float = 1.7 ## Original Player Height (Should be 1.7)
@export var VaultCollisionHeight : float = 0.4 ## How Tall is the player when vaulting
@export var VaultHeightBoost : float = 0.1 ## Translates player over obstacle. We need to "pop" over the obstacle by moving the collision up.
@export var VaultTimer : float = 0.25 ## Turns off the Vault State after acting.

func _physics_process(_delta : float) -> void:
	if Source.isHanging:
		if Input.is_action_just_pressed("MV_Jump"):
			_clamber_ledge()
		elif Input.is_action_just_pressed("MV_Crouch"):
			_release_ledge()
		return
	if Input.is_action_pressed("MV_Jump"):
		if Source.is_on_floor() and Source.isSprinting and Input.is_action_pressed("MV_Forward"):
			_can_vault()
			return
		_detect_ledge()


func _detect_ledge(): ## Is there a Ledge Here?
	if !ClamberCast.is_colliding():
		return
	if !ClamberProbeHeight.is_colliding():
		return
	var TargetTopSurface = ClamberProbeHeight.get_collision_point().y
	var HeightDiff = TargetTopSurface - Source.global_position.y
	if HeightDiff < 0.15:
		return
	elif HeightDiff < 2.0:
		if Source.velocity.y < 1.5:
			_grab_ledge()
	else:
		return


func _grab_ledge(): ## Ledge Grab Logic. Cannot Look or Move. Only Ascend or Drop
	if GrabLedgeSound:
		AudioPlayer.stream = GrabLedgeSound
		AudioPlayer.play()
	AnimManager._override_travel("aHang")
	Source.velocity = Vector3.ZERO
	Source.isHanging = true
	Jump.WasAirborne = false
	var LedgeSurface = ClamberProbeHeight.get_collision_point()
	var WallNormal = ClamberCast.get_collision_normal(0)
	var WallRight = Vector3.UP.cross(WallNormal).normalized()
	var HandOffset = Vector3(0, LedgeYOffset, LedgeZOffset)
	var HangPos = LedgeSurface - (Source.global_transform.basis * HandOffset)
	# Position Hand Markers
	HandTargetL.global_position = LedgeSurface + (WallRight * -0.25) + Vector3(0, 0.01, 0)
	HandTargetR.global_position = LedgeSurface + (WallRight * 0.25) + Vector3(0, 0.01, 0)
	var SnapTween = get_tree().create_tween()
	SnapTween.tween_property(Source, "global_position", HangPos, 0.12)\
		.set_trans(Tween.TRANS_SINE)
	SnapTween.tween_callback(func():
		IK_ArmL.active = false
		IK_ArmR.active = false
		AnimManager.AnimOverride = false)
		
func _release_ledge():
	IK_ArmL.active = false
	IK_ArmR.active = false
	Source.isHanging = false
	CameraPivot.rotation.y = 0.0
	Source.velocity.y = -2.0

func _clamber_ledge():
	if ClamberSound:
		AudioPlayer.stream = ClamberSound
		AudioPlayer.play()
	Jump.WasAirborne = false
	IK_ArmL.active = false
	IK_ArmR.active = false
	var ClamberTimer = AnimManager._get_anim_length("aClamber")
	if ClamberProbeCeiling.is_colliding():
		AnimManager._override_travel("aClamberCrouch")
		Crouch._toggle_crouch()
	elif !ClamberProbeCeiling.is_colliding():
		AnimManager._override_travel("aClamber")
	Source.isClambering = true
	Source.isHanging = false
	CameraPivot.rotation.y = 0.0
	## Clamber Movement (Duplicate of Vault)
	#TODO Split this movement into its own function (But, does vaulting need a seperate force than clambering?)
	var ClamberDirection = (-Source.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	Source.velocity.x = ClamberDirection.x * ClamberForwardBoost
	Source.velocity.z = ClamberDirection.z * ClamberForwardBoost
	Source.velocity.y = ClamberForce
	Source.PlayerCollision.shape.height = ClamberCollisionHeight ## Without this, can't clear a ledge 😬
	Source.position.y = lerp(Source.position.y, Source.position.y + ClamberHeightBoost, 1) ## And without this, I clip into the ledge's floor 😬
	get_tree().create_timer(ClamberTimer).timeout.connect(func():
		_end_clamber())

func _end_clamber() -> void:
	Source.PlayerCollision.shape.height = CollisionInitHeight
	Source.isClambering = false
	AnimManager.AnimOverride = false

func _can_vault():
	if !ClamberCast.is_colliding() or ClamberProbeCeiling.is_colliding():
		return
	if !VaultProbeDepth.is_colliding() and ClamberCast.is_colliding():
		_vault()
	return

func _vault() -> void:
	if VaultSound:
		AudioPlayer.stream = VaultSound
		AudioPlayer.play()
	AnimManager._override_travel("aVault")
	Jump.WasAirborne = false
	Source.isVaulting = true
	## Here's the Vault Functionality. The meat of the action.
	var VaultDirection = (-Source.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	Source.velocity.x = VaultDirection.x * (Source.MoveSpeed + VaultForwardBoost)
	Source.velocity.z = VaultDirection.z * (Source.MoveSpeed + VaultForwardBoost)
	Source.velocity.y = VaultForce
	Source.PlayerCollision.shape.height = VaultCollisionHeight
	Source.position.y = Source.position.y + VaultHeightBoost
	get_tree().create_timer(VaultTimer).timeout.connect(_end_vault) ## Time out the vault to reset the state flags and player's height

func _end_vault() -> void:
	Source.PlayerCollision.shape.height = CollisionInitHeight
	Source.isVaulting = false
	AnimManager.AnimOverride = false
