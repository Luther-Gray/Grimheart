@icon("res://addons/IconGodotNode/node_3D/icon_loader.png")
extends Node3D

@export var Source: CharacterBody3D
@onready var ClamberTarget: RayCast3D = $"../ClamberTargetRaycast"
@onready var ClamberCast: ShapeCast3D = $"../ClamberShapecast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"

# Vault
var VaultDistance : float = 1.5
# Ledge Grab
var LedgeYOffset : float = 1.2
var LedgeZOffset : float = -0.2
# Clamber
var ClamberUpTime : float = 0.48
var ClamberOverTime : float = 0.15

func _physics_process(_delta: float) -> void:
	if Source.isHanging:
		var LedgeInput = Input.get_axis("MV_Left", "MV_Right")
		_wall_check(LedgeInput)
		
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
	elif HeightDiff < 0.6: #Knee Height - Step Over
		if Input.is_action_pressed("MV_Forward"):
			_step_over()
	elif HeightDiff < 1.2: #Waist Height - Vault
		if Input.is_action_pressed("MV_Forward"):
			_vault()
	elif HeightDiff < 2.0: # Climbable!
		if Source.isFalling or Source.velocity.y < 1.5:
			_grab_ledge()
	else: # Too Tall - Ignore
		return

#// Vault
func _vault():
	AnimManager._override_travel("aVault")
	var WallNormal = ClamberCast.get_collision_normal(0)
	var VaultTarget = ClamberTarget.get_collision_point() + Vector3(0, 0.3, 0)
	var VaultEnd = VaultTarget + (-WallNormal * VaultDistance)
	var CastObject = ClamberCast.get_collider(0)
	if CastObject:
		Source.add_collision_exception_with(CastObject)
	var VaultTween = get_tree().create_tween()
	VaultTween.tween_property(Source, "global_position", VaultTarget, 0.15).set_trans(Tween.TRANS_SINE)
	VaultTween.tween_property(Source, "global_position", VaultEnd, 0.2).set_trans(Tween.TRANS_SINE)
	VaultTween.tween_callback(func():
		if CastObject:
			Source.remove_collision_exception_with(CastObject)
		AnimManager.AnimOverride = false)
	print("Vault")
	
#// Ledge Grab
func _grab_ledge():
	AnimManager._override_travel("aHang")
	Source.velocity = Vector3.ZERO
	Source.isHanging = true
	var LedgeSurface = ClamberTarget.get_collision_point().y
	var WallNormal = ClamberCast.get_collision_normal(0)
	var HangPos = Vector3(
		Source.global_position.x,
		LedgeSurface - LedgeYOffset,
		Source.global_position.z
	) + (WallNormal * LedgeZOffset)
	var SnapTween = get_tree().create_tween()
	SnapTween.tween_property(Source, "global_position", HangPos, 0.12)\
		.set_trans(Tween.TRANS_SINE)
	SnapTween.tween_callback(func():
		AnimManager.AnimOverride = false)
	print("Ledge Grab")

#// Ledge Release
func _release_ledge():
	Source.isHanging = false
	Source.velocity.y = -2.0
	print("Let Go")

#// Ledge Pull Up
func _clamber_ledge():
	var ClamberTime = AnimManager._get_anim_length("aLedgeClimb")
	AnimManager._override_travel("aLedgeClimb")
	var HalfHeight = Source.PlayerCollision.shape.height / 2.0 + 0.05
	var WallNormal = ClamberCast.get_collision_normal(0)
	var Surface = ClamberTarget.get_collision_point()
	var LedgeUp = Vector3(Source.global_position.x, Surface.y + HalfHeight, Source.global_position.z)
	var LedgeOver = LedgeUp + (-WallNormal * 0.3)
	### In this Tween, we're doing the clamber in two steps. Up -> Over.
	var ClamberTween = get_tree().create_tween()
	ClamberTween.tween_property(Source, "global_position", LedgeUp, ClamberTime * 0.9).set_trans(Tween.TRANS_SINE)
	ClamberTween.tween_property(Source, "global_position", LedgeOver, ClamberTime * 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	ClamberTween.tween_callback(func():
		Source.velocity = Vector3.ZERO
		Source.isHanging = false
		AnimManager.AnimOverride = false)
	
#// Step Over
func _step_over():
	Source.velocity.y = 0.15
	print("Step Over")
	
# Move on Ledge
func _wall_check(input_x: float) -> void:
	if !ClamberCast.is_colliding():
		_release_ledge()
		return
	var WallNormal = ClamberCast.get_collision_normal(0)
	var LateralDirection = Vector3.UP.cross(WallNormal).normalized()
	Source.velocity.x = LateralDirection.x * input_x * Source.Stat.ClimbSpeed
	Source.velocity.z = LateralDirection.z * input_x * Source.Stat.ClimbSpeed
