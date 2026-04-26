@icon("res://addons/IconGodotNode/node_3D/icon_cell.png")
extends Node3D

@onready var PlayerCollision: CollisionShape3D = $"../PlayerCollision"
@onready var CrouchRaycast: RayCast3D = $"../CrouchRaycast"

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@export var Settings : Resource

#// Crouch Values
var InitPlayerHeight : float = 2.0
var InitColPosition : float = 1.0
var InitMarkerPos : float = 0.14
var TargetPlayerHeight : float = 0.9
var TargetColPosition : float = 0.5
var TargetMarkerPos : float = -1

func _physics_process(_delta: float) -> void:
	if Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch"):
			_toggle_crouch()
	elif !Settings.CrouchToggle:
		if Input.is_action_pressed("MV_Crouch"):
			_hold_crouch()
		else:
			_release_crouch()

func _toggle_crouch():
	if !Source.isCrouched:
		PlayerCollision.shape.height = TargetPlayerHeight
		PlayerCollision.position.y = TargetColPosition
		CameraPivot.CameraMarker.position.y = TargetMarkerPos
		Source.isCrouched = true
	elif Source.isCrouched and !CrouchRaycast.is_colliding():
		PlayerCollision.shape.height = InitPlayerHeight
		PlayerCollision.position.y = InitColPosition
		CameraPivot.CameraMarker.position.y = InitMarkerPos
		Source.isCrouched = false

func _hold_crouch():
	if !Source.isCrouched:
		PlayerCollision.shape.height = TargetPlayerHeight
		PlayerCollision.position.y = TargetColPosition
		CameraPivot.CameraMarker.position.y = TargetMarkerPos
		Source.isCrouched = true
		
func _release_crouch():
	if Source.isCrouched and !CrouchRaycast.is_colliding():
		PlayerCollision.shape.height = InitPlayerHeight
		PlayerCollision.position.y = InitColPosition
		CameraPivot.CameraMarker.position.y = InitMarkerPos
		Source.isCrouched = false
