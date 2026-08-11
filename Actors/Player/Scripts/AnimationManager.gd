@icon("res://addons/IconGodotNode/node_3D/icon_animation.png")
extends Node
class_name AnimationManager

@export var AnimationDirector : AnimationTree
@export var Source: CharacterBody3D
@export var AnimPlayer : AnimationPlayer

var MovementPlayback : AnimationNodeStateMachinePlayback
var CombatPlayback : AnimationNodeStateMachinePlayback
var CurrentMoveDirection : Vector2 = Vector2.ZERO
var TargetMoveDirection : Vector2 = Vector2.ZERO
var AnimationSpeed : int = 10 ## Influences the Animation Speed, right now, this is for aWalkSpace.
var AnimOverride : bool = false ## AnimOverride, when true, allows an external system/function to take control of the Locomotion State Machine. Default Animations in _process are blocked.

func _ready() -> void:
	MovementPlayback = AnimationDirector.get("parameters/LocomotionStateMachine/playback")
	CombatPlayback = AnimationDirector.get("parameters/CombatStateMachine/playback")
	AnimationDirector.set("parameters/StateMachineBlend/blend_amount", 0.0)
# Priority Matters
func _process(_delta: float) -> void:
	### Primary Anim State Tree (Locomotion)
	if AnimOverride:
		return
	if Source.isHanging:
		MovementPlayback.travel("aHang")
	elif Source.isFalling:
		MovementPlayback.travel("aFall")
	elif Source.isSprinting:
		MovementPlayback.travel("aSprint")
	elif Source.isMoving and Source.isCrouched:
		MovementPlayback.travel("aCrouchSpace")
	elif Source.isMoving:
		MovementPlayback.travel("aWalkSpace")
	elif Source.isCrouched:
		MovementPlayback.travel("aCrouchIdle")
	else:
		MovementPlayback.travel("aIdle")
	### Secondary Anim State Tree (Combat/Interactions)
	if Input.is_action_just_pressed("ATK_Right") or Input.is_action_just_pressed("ATK_Left"):
		Source.isUnsheathed = true
		CombatPlayback.travel("aIdleUnarmed")
		AnimationDirector.set("parameters/StateMachineBlend/blend_amount", 1.0)
	elif Input.is_action_just_pressed("ATK_Reload"): 
		AnimationDirector.set("parameters/StateMachineBlend/blend_amount", 0.0)

func _physics_process(delta: float) -> void:
	TargetMoveDirection = Source.InputDir
	CurrentMoveDirection = lerp(CurrentMoveDirection, TargetMoveDirection, AnimationSpeed * delta)
	if !Source.isCrouched and !Source.isWallRunning:
		AnimationDirector.set("parameters/LocomotionStateMachine/aWalkSpace/blend_position", Vector2(CurrentMoveDirection.x, -CurrentMoveDirection.y))
	elif Source.isCrouched:
		AnimationDirector.set("parameters/LocomotionStateMachine/aCrouchSpace/blend_position", Vector2(CurrentMoveDirection.x, -CurrentMoveDirection.y))
	

func _one_shot(Anim: String) -> void: ##Helper Method for One Shot Animations
	AnimationDirector.set("parameters/LocomotionStateMachine/" + Anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _variant_travel(NestedAnim: String, State: String) -> void: ##Helper for Animations with multiple permutations.
	AnimOverride = true
	MovementPlayback.travel(NestedAnim)
	var NestedPlayback: AnimationNodeStateMachinePlayback = AnimationDirector.get("parameters/LocomotionStateMachine/" + NestedAnim + "/playback")
	NestedPlayback.travel(State)
	
func _override_travel(State: String) -> void: ##Helper for Animations that need to override others.
	AnimOverride = true
	MovementPlayback.travel(State)

func _get_anim_length(AnimationName: String) -> float: ## Helper to Sync Animation Length to a Tween
	var Anim = AnimPlayer.get_animation(AnimationName)
	if Anim:
		return Anim.length
	return 0.5
