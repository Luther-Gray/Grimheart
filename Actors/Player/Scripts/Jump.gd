@icon("res://addons/IconGodotNode/node_3D/icon_boots.png")
extends Node

@export var Source: CharacterBody3D

@onready var AnimManager: AnimationManager = $"../AnimCenter"

var CoyoteTimer : float = 0.0
const CoyoteDuration : float = 0.15
var FallDistance : float = 0.0
var FallDamage : float = FallDistance * 3.0
const FallDamageThreshold : float = 3.0
var FallInit : float = 0.0
var WasAirborn : bool = false
var VariableJumpMult : float = 0.35

func _physics_process(delta: float) -> void:
# Handle Fall
	if not Source.is_on_floor():
		Source.isFalling = Source.velocity.y < 0
		if !WasAirborn:
			FallInit = Source.global_position.y
			WasAirborn = true
	else:
		FallInit = maxf(FallInit, Source.global_position.y)
		if WasAirborn:
			FallDistance = abs(FallInit - Source.global_position.y)
			if FallDistance >= FallDamageThreshold:
				Source.Vitals._vital_impact("Health", FallDamage)
				print(Source.Vitals.Health)
			WasAirborn = false
		Source.isFalling = false
		Source.isJumping = false
		AnimManager.AnimOverride = false
		
# Handle jump.
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
	if Source.isMoving:
		AnimManager._variant_travel("aJumpVariants", ["aLeapL", "aLeapR"].pick_random())
