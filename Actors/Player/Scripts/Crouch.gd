@icon("res://addons/IconGodotNode/node_3D/icon_cell.png")
extends Node3D

@onready var CrouchRay: RayCast3D = $"../CrouchRaycast"

@export var Source : CharacterBody3D
@export var CameraPivot : Node3D
@export var CameraMarker : Marker3D

#// Crouch Values
var InitPlayerHeight : float = 1.7
var InitColPosition : float = 0.85
var InitMarkerPos : float = 1.45
var TargetPlayerHeight : float = 0.95
var TargetColPosition : float = 0.5
var TargetMarkerPos : float = 0.90

func _physics_process(_delta: float) -> void:
	if Source.isSliding:
		return
	if Source.Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch") and !Source.isHanging and !Source.isSprinting:
			_toggle_crouch()
	elif !Source.Settings.CrouchToggle:
		if Input.is_action_pressed("MV_Crouch")  and !Source.isHanging and !Source.isSprinting:
			_hold_crouch()
		else:
			_release_crouch()

func _toggle_crouch():
	if !Source.isCrouched and !Source.isMoving:
		Source.PlayerCollision.shape.height = TargetPlayerHeight
		Source.PlayerCollision.position.y = TargetColPosition
		CameraMarker.position.y = TargetMarkerPos
		Source.isCrouched = true
		Source.isSprinting = false
		Source.MoveSpeed = Source.Stat.CrouchSpeed
	elif Source.isCrouched and !CrouchRay.is_colliding():
		Source.PlayerCollision.shape.height = InitPlayerHeight
		Source.PlayerCollision.position.y = InitColPosition
		CameraMarker.position.y = InitMarkerPos
		Source.isCrouched = false
		Source.MoveSpeed = Source.Stat.WalkSpeed

func _hold_crouch():
	if !Source.isCrouched:
		Source.PlayerCollision.shape.height = TargetPlayerHeight
		Source.PlayerCollision.position.y = TargetColPosition
		CameraMarker.position.y = TargetMarkerPos
		Source.isCrouched = true
		Source.isSprinting = false
		Source.MoveSpeed = Source.Stat.CrouchSpeed
		
func _release_crouch():
	if Source.isCrouched and !CrouchRay.is_colliding():
		Source.PlayerCollision.shape.height = InitPlayerHeight
		Source.PlayerCollision.position.y = InitColPosition
		CameraMarker.position.y = InitMarkerPos
		Source.MoveSpeed = Source.Stat.WalkSpeed
		Source.isCrouched = false
