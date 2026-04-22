@icon("res://addons/IconGodotNode/node/icon_animation.png")
extends Node
class_name  AnimationManager

@export var AnimTree : AnimationTree
@export var Source: CharacterBody3D

var StateMachine : AnimationNodeStateMachinePlayback
var CurrentMoveDirection : Vector2 = Vector2.ZERO
var TargetMoveDirection : Vector2 = Vector2.ZERO
var AnimationSpeed : int = 5

func _ready() -> void:
	#//Turn Animation Manager off for Testing Mechanics.
	process_mode = Node.PROCESS_MODE_DISABLED
	StateMachine = AnimTree.get("parameters/playback")
	

# Priority Matters
func _process(_delta: float) -> void:
	if Source.isUnsheathed:
		StateMachine.travel("aIdleArmed")
	elif Source.isJumping:
		StateMachine.travel("aJump")
	elif Source.isFalling:
		StateMachine.travel("aFall")
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
