extends Node
class_name  AnimationManager

@export var AnimTree : AnimationTree
@export var Source: CharacterBody3D

var StateMachine : AnimationNodeStateMachinePlayback

func _ready() -> void:
	StateMachine = AnimTree.get("parameters/playback")
	

func _process(_delta: float) -> void:
	if Source.isMoving and !Source.isSprinting:
		StateMachine.travel("aWalk")
	elif Source.isSprinting:
		StateMachine.travel("aSprint")
	else:
		StateMachine.travel("aIdle")
