@icon("res://addons/IconGodotNode/node_3D/icon_boots.png")
extends Node

@export var Source: CharacterBody3D
@export var HardLandingSound : AudioStream
@export var RollSound : AudioStream
@export var AudioPlayer : AudioStreamPlayer3D
@onready var AnimManager: AnimationManager = $"../AnimCenter"
# Coyote Time
var CoyoteTimer : float
const CoyoteDuration : float = 0.15
# Fall Damage
var FallPeak : float
var FallDistance : float
const FallDamageThreshold : float = 3.0
const FallDamageMultiplier : float = 3.0
var FallStunDuration : float = 0.3
var FallStunTimer : float
# Roll Window
var RollWindow : float = 0.0
var RollTimer: float = 0.0
# Variable Jump Height
var WasAirborne : bool = false
var VariableJumpMult : float = 0.35

func _physics_process(delta: float) -> void:
	_roll_buffer(delta)
	_calc_fall(delta)
	_fall_stun(delta)
	_roll_timer(delta)
	
	if !Source.Status.Stunned:
		_jump(delta)

func _jump(delta: float):
	if Input.is_action_just_pressed("MV_Jump") and CoyoteTimer > 0:
		CoyoteTimer = 0
		Source.isJumping = true
		Source.velocity.y = Source.Stat.JumpStrength
		_jump_anim()
	if Input.is_action_just_released("MV_Jump") and Source.velocity.y > 0 and Source.isJumping:
		Source.velocity.y *= VariableJumpMult
	if Source.is_on_floor():
		CoyoteTimer = CoyoteDuration
	else:
		CoyoteTimer -= delta

func _jump_anim():
	if !Source.isMoving:
		AnimManager._variant_travel("aJumpVariants", "aJump")
	elif Source.isMoving:
		AnimManager._variant_travel("aJumpVariants", ["aLeapL", "aLeapR"].pick_random())
		
func _calc_fall(_delta: float) -> void:
	if not Source.is_on_floor():
		Source.isFalling = Source.velocity.y < 0
		if Source.isFalling and AnimManager.AnimOverride:
			AnimManager.AnimOverride = false
		if !WasAirborne:
			FallPeak = Source.global_position.y
			WasAirborne = true
		else:
			FallPeak = maxf(FallPeak, Source.global_position.y)
	else:
		Source.isFalling = false
		Source.isJumping = false
		if WasAirborne:
			WasAirborne = false
			FallDistance = abs(FallPeak - Source.global_position.y)
			if FallDistance >= FallDamageThreshold and RollWindow <= 0.0:
				var FallDamage: float = (FallDistance - FallDamageThreshold) * FallDamageMultiplier
				Source.Vitals._vital_impact("Health", FallDamage)
				AnimManager._override_travel("aLanding")
				if HardLandingSound:
					AudioPlayer.stream = HardLandingSound
					AudioPlayer.play()
				Source.Status._stunned(FallStunDuration)
				Source.velocity = Vector3.ZERO
			elif FallDistance >= FallDamageThreshold and RollWindow > 0.0:
				if HardLandingSound:
					AudioPlayer.stream = RollSound
					AudioPlayer.play()
				RollWindow = 0.0
				RollTimer = AnimManager._get_anim_length("aRoll")
				Source.isSprinting = true
				AnimManager._override_travel("aRoll")
			else:
				AnimManager.AnimOverride = false
				
func _fall_stun(delta):
	if Source.Status.Stunned:
		Source.Status.StunTimer -= delta
		if Source.Status.StunTimer <= 0.0:
			Source.Status.StunTimer = 0.0
			Source.Status.Stunned = false
			AnimManager.AnimOverride = false
func _roll_buffer(delta):
	if Input.is_action_just_pressed("MV_Sprint"):
		RollWindow = AnimManager._get_anim_length("aRoll")
	elif RollWindow > 0.0:
		RollWindow -= delta
func _roll_timer(delta):
	if RollTimer > 0.0:
		RollTimer -= delta
	if RollTimer <= 0.0:
		RollTimer = 0.0
		AnimManager.AnimOverride = false
