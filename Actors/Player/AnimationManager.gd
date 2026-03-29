extends Node3D 
class_name  AnimationManager

#@onready var AnimTree: AnimationTree = $AnimationTree
#var Playback = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
#@onready var Target: Player = $".."
#
#func _process(_delta: float) -> void:
	#if Target.isMoving:
		#Playback.travel("aWalk")
	#else:
		#Playback.travel("aIdle")
