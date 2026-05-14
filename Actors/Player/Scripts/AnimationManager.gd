@icon("res://addons/IconGodotNode/node_3D/icon_animation.png")
extends Node
class_name  AnimationManager

@export var AnimTree : AnimationTree
@export var Source: CharacterBody3D

var StateMachine : AnimationNodeStateMachinePlayback
var CurrentMoveDirection : Vector2 = Vector2.ZERO
var TargetMoveDirection : Vector2 = Vector2.ZERO
var AnimationSpeed : int = 10
var AnimOverride : bool = false
var AnimPlayer : AnimationPlayer

func _ready() -> void:
	StateMachine = AnimTree.get("parameters/playback")
	AnimPlayer = Source.find_child("AnimationPlayer", true, false)
	#//Turn Animation Manager off for Testing Mechanics.
	#process_mode = Node.PROCESS_MODE_DISABLED


# Priority Matters
func _process(_delta: float) -> void:
	if AnimOverride:
		return
	if Source.isUnsheathed:
		StateMachine.travel("aIdleArmed")
	elif Source.isHanging:
		StateMachine.travel("aHang")
	elif Source.isMoving and !Source.isSprinting:
		StateMachine.travel("aWalkSpace")
	elif Source.isSprinting:
		StateMachine.travel("aSprint")
	else:
		StateMachine.travel("aIdle")
		
func _physics_process(delta: float) -> void:
	TargetMoveDirection = Source.InputDir
	CurrentMoveDirection = lerp(CurrentMoveDirection, TargetMoveDirection, AnimationSpeed * delta)
	AnimTree.set("parameters/aWalkSpace/blend_position", CurrentMoveDirection)
	
#// Helper Method for One Shot Animations
func _one_shot(Anim: String) -> void:
	AnimTree.set("parameters/" + Anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#// Helper for Animations with multiple permutations.
func _variant_travel(NestedAnim: String, State: String) -> void:
	AnimOverride = true
	StateMachine.travel(NestedAnim)
	var NestedPlayback: AnimationNodeStateMachinePlayback = AnimTree.get("parameters/" + NestedAnim + "/playback")
	NestedPlayback.travel(State)
	
#// Helper for Animations that need to override others.
func _override_travel(State: String) -> void:
	AnimOverride = true
	StateMachine.travel(State)

#// Helper to Sync Animation Length to a Tween
func _get_anim_length(AnimationName: String) -> float:
	var Anim = AnimPlayer.get_animation(AnimationName)
	if Anim:
		return Anim.length
	return 0.5
