@icon("res://addons/IconGodotNode/node_3D/icon_sound.png")
extends Node3D

@export_category("Functionality")
@export var Source: CharacterBody3D
@export var Skeleton: Skeleton3D
@export_category("Sound Files")
@export var ConcreteSteps: AudioStreamRandomizer

var LeftFootId : int
var RightFootId : int
var LeftFootLastY : float = 0.0
var RightFootLastY : float = 0.0
var FloorLocation : float = 0.0

# Find Foot Bones.
func _ready() -> void:
	LeftFootId = Skeleton.find_bone("bFoot.L")
	RightFootId = Skeleton.find_bone("bFoot.R")

# If Foot Bone is "close to the floor" play a footstep sound.
func _physics_process(_delta: float) -> void:
	if !Source.is_on_floor() or !Source.isMoving or Source.isHanging:
		return
	
	var LeftY = Skeleton.get_bone_global_pose(LeftFootId).origin.y
	var RightY = Skeleton.get_bone_global_pose(RightFootId).origin.y
	
	# Fire when foot crosses downward through contact threshold
	if LeftY < LeftFootLastY and LeftFootLastY - LeftY > 0.005:
		if LeftY <= _get_floor_y() + 0.08:
			_play_step()
	if RightY < RightFootLastY and RightFootLastY - RightY > 0.005:
		if RightY <= _get_floor_y() + 0.08:
			_play_step()
	
	LeftFootLastY = LeftY
	RightFootLastY = RightY

func _get_floor_y() -> float:
	return Source.global_position.y - (Source.PlayerCollision.shape.height / 2.0)

func _play_step():
	pass
