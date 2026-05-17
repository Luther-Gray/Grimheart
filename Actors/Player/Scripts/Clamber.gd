@icon("res://addons/IconGodotNode/node_3D/icon_loader.png")
extends Node3D

@export var Source: CharacterBody3D
@onready var ClamberTarget: RayCast3D = $"../ClamberTargetRaycast"
@onready var ClamberCast: ShapeCast3D = $"../ClamberShapecast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var CameraPivot: Node3D = $"../PlayerCollision/CameraPivot"
@onready var DEV_Target: MeshInstance3D = $"../../DEV_Target"


#// IK Locations
@export var IK_ArmL: TwoBoneIK3D
@export var IK_ArmR: TwoBoneIK3D
@export var HandTargetL: Marker3D
@export var HandTargetR: Marker3D


# Ledge Grab
@export_range(1.0, 3.0, 0.1) var LedgeYOffset : float = 1.4 # Higher Numbers mean Lower Down.
@export_range(-1.0, 1.0, 0.1) var LedgeZOffset : float = -0.9 # Negative Moves away from Ledge.
# Clamber Boost - Magic number to make the clamber actually go up. No idea why delta alone isn't enough.
var ClamberBoost : float = 10

func _physics_process(_delta: float) -> void:
	if Source.isClambering:
		var RootMotion = AnimManager.AnimTree.get_root_motion_position()
		Source.global_position += (Source.global_transform.basis * RootMotion) * ClamberBoost
		Source.velocity = Vector3.ZERO
		print(Source.velocity)
		return
	if Source.isHanging:
		var _LedgeInput = Input.get_axis("MV_Left", "MV_Right")
		#_wall_check(LedgeInput)
		
		if Input.is_action_just_pressed("MV_Jump"):
			_clamber_ledge()
		elif Input.is_action_just_pressed("MV_Crouch"):
			_release_ledge()
		return
	if Input.is_action_pressed("MV_Jump"):
		_detect_ledge()

	#// Detect Ledge
func _detect_ledge():
	if !ClamberCast.is_colliding():
		return
	if !ClamberTarget.is_colliding():
		return
	var TargetTopSurface = ClamberTarget.get_collision_point().y
	var HeightDiff = TargetTopSurface - Source.global_position.y
	
	#// Height Chart
	if HeightDiff < 0.15: # Too Small - Ignore
		return
	elif HeightDiff < 1.2: #Waist Height - Vault
		if Input.is_action_pressed("MV_Forward") and Source.is_on_floor():
			_vault()
	elif HeightDiff < 2.0: # Climbable!
		if Source.velocity.y < 1.5:
			_grab_ledge()
	else: # Too Tall - Ignore
		return
		
#// Ledge Grab
func _grab_ledge():
	AnimManager._override_travel("aHang")
	Source.velocity = Vector3.ZERO
	Source.isHanging = true
	var LedgeSurface = ClamberTarget.get_collision_point()
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
		IK_ArmL.active = true
		IK_ArmR.active = true
		AnimManager.AnimOverride = false)
	DEV_Target.global_position = LedgeSurface
	print("Ledge Grab")

#// Ledge Release
func _release_ledge():
	IK_ArmL.active = false
	IK_ArmR.active = false
	Source.isHanging = false
	CameraPivot.rotation.y = 0.0
	Source.velocity.y = -2.0
	print("Let Go")

#// Ledge Pull Up
func _clamber_ledge():
	IK_ArmL.active = false
	IK_ArmR.active = false
	var ClamberTimer = AnimManager._get_anim_length("root_aClamber")
	AnimManager._override_travel("root_aClamber")
	Source.isClambering = true
	Source.isHanging = false
	CameraPivot.rotation.y = 0.0
	get_tree().create_timer(ClamberTimer).timeout.connect(func():
		Source.isClambering = false
		AnimManager.AnimOverride = false)
		
#// Vault
func _vault():
	AnimManager._override_travel("aVault")
		# Speed Boost whenever you successfully vault
	Source.MoveSpeed += 4.5
	get_tree().create_timer(1.0).timeout.connect(func(): Source.MoveSpeed -= 4.5)
	
	Source.isVaulting = true
	var VaultTarget = ClamberTarget.get_collision_point().y
	var VaultDirection = -Source.global_transform.basis.z
	var VaultBoost : float = 1.8
	
	# Disable Collision
	var CastObject = ClamberCast.get_collider(0)
	if CastObject:
		Source.add_collision_exception_with(CastObject)
	# Boost Vault
	var VaultTween = get_tree().create_tween()
	VaultTween.set_parallel(true)
	VaultTween.tween_property(Source, "global_position:y", VaultTarget, 0.1).set_trans(Tween.TRANS_SINE)
	VaultTween.tween_property(Source, "global_position:x", Source.global_position.x + VaultDirection.x * VaultBoost, 0.1).set_trans(Tween.TRANS_SINE)
	VaultTween.tween_property(Source, "global_position:z", Source.global_position.z + VaultDirection.z * VaultBoost, 0.25).set_trans(Tween.TRANS_SINE)
	VaultTween.set_parallel(false)
	
	VaultTween.tween_callback(func():
		if CastObject:
			Source.remove_collision_exception_with(CastObject)
		AnimManager.AnimOverride = false
		Source.isVaulting = false
		
		)
	print("Vault")
	
# Move on Ledge
func _wall_check(input_x: float) -> void:
	if !ClamberCast.is_colliding():
		_release_ledge()
		return
	var WallNormal = ClamberCast.get_collision_normal(0)
	var LateralDirection = Vector3.UP.cross(WallNormal).normalized()
	Source.velocity.x = LateralDirection.x * input_x * Source.Stat.ClimbSpeed
	Source.velocity.z = LateralDirection.z * input_x * Source.Stat.ClimbSpeed
