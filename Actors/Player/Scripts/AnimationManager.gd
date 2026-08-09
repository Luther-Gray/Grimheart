@icon("res://addons/IconGodotNode/node_3D/icon_animation.png")
extends Node
class_name  AnimationManager

@export var MovementTree : AnimationTree
@export var CombatTree : AnimationTree
@export var Source: CharacterBody3D

var MovementMachine : AnimationNodeStateMachinePlayback
var CombatMachine : AnimationNodeStateMachinePlayback
var CurrentMoveDirection : Vector2 = Vector2.ZERO
var TargetMoveDirection : Vector2 = Vector2.ZERO
var AnimationSpeed : int = 10 # Influences the Animation Speed, right now, this is for aWalkSpace.
var AnimOverride : bool = false
var AnimPlayer : AnimationPlayer


func _ready() -> void:
	MovementMachine = MovementTree.get("parameters/playback")
	CombatMachine = CombatTree.get("parameters/playback")
	CombatTree.active = false
	AnimPlayer = Source.find_child("AnimationPlayer", true, false)
	#//Turn Animation Manager off DEV STUFF
	#process_mode = Node.PROCESS_MODE_DISABLED

# Priority Matters
func _process(_delta: float) -> void:
	if AnimOverride:
		return
	### Primary Anim State Tree (Locomotion)
	if Source.isHanging:
		MovementMachine.travel("aHang")
	elif Source.isFalling:
		MovementMachine.travel("aFall")
	elif Source.isSprinting:
		MovementMachine.travel("aSprint")
	elif Source.isMoving and Source.isCrouched:   # more specific first
		MovementMachine.travel("aCrouchSpace")
	elif Source.isMoving:
		MovementMachine.travel("aWalkSpace")
	elif Source.isCrouched:
		MovementMachine.travel("aCrouchIdle")
	else:
		MovementMachine.travel("aIdle")
	### Secondary Anim State Tree (Combat/Interactions)
	if Input.is_action_just_pressed("ATK_Right") or Input.is_action_just_pressed("ATK_Left"):
		CombatTree.active = true
	if Source.isUnsheathed:
		CombatMachine.travel("aIdleArmed")

func _physics_process(delta: float) -> void:
	TargetMoveDirection = Source.InputDir
	CurrentMoveDirection = lerp(CurrentMoveDirection, TargetMoveDirection, AnimationSpeed * delta)
	if !Source.isCrouched and !Source.isWallRunning:
		MovementTree.set("parameters/aWalkSpace/blend_position", Vector2(CurrentMoveDirection.x, -CurrentMoveDirection.y))
	elif Source.isCrouched:
		MovementTree.set("parameters/aCrouchSpace/blend_position", Vector2(CurrentMoveDirection.x, -CurrentMoveDirection.y))
	
#// Helper Method for One Shot Animations
func _one_shot(Anim: String) -> void:
	MovementTree.set("parameters/" + Anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#// Helper for Animations with multiple permutations.
func _variant_travel(NestedAnim: String, State: String) -> void:
	AnimOverride = true
	MovementMachine.travel(NestedAnim)
	var NestedPlayback: AnimationNodeStateMachinePlayback = MovementTree.get("parameters/" + NestedAnim + "/playback")
	NestedPlayback.travel(State)
	
#// Helper for Animations that need to override others.
func _override_travel(State: String) -> void:
	AnimOverride = true
	MovementMachine.travel(State)

#// Helper to Sync Animation Length to a Tween
func _get_anim_length(AnimationName: String) -> float:
	var Anim = AnimPlayer.get_animation(AnimationName)
	if Anim:
		return Anim.length
	return 0.5
