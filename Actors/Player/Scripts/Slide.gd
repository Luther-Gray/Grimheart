@icon("res://addons/IconGodotNode/node_3D/icon_wheel.png")
extends Node3D

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var CrouchRay: RayCast3D = $"../PlayerCollision/CameraPivot/CrouchRaycast"

#// Crouch Values
var InitPlayerHeight : float = 1.7
var InitColPosition : float = 0.85
var InitMarkerPos : float = 0.14
var TargetPlayerHeight : float = 0.7
var TargetColPosition : float = 0.5
var TargetMarkerPos : float = -1

#// Slide Values
const SlideDuration : float = 0.8
const SlideBoost : float = 2.0

func _physics_process(_delta: float) -> void:
	if Source.isSliding:
		return
	if Source.Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch") and Source.isSprinting and Source.is_on_floor():
			_slide()
	elif !Source.Settings.CrouchToggle:
		if Input.is_action_pressed("MV_Crouch") and Source.isSprinting and Source.is_on_floor():
			_slide()

func _slide():
	Source.PlayerCollision.shape.height = TargetPlayerHeight
	Source.PlayerCollision.position.y = TargetColPosition
	CameraPivot.CameraMarker.position.y = TargetMarkerPos
	Source.isSliding = true
	Source.isCrouched = true
	var SlideDirection = -Source.global_transform.basis.z
	Source.velocity += SlideDirection * SlideBoost
	AnimManager._override_travel("aSlide")
	get_tree().create_timer(SlideDuration).timeout.connect(_end_slide)
	

func _end_slide():
	Source.isSliding = false
	AnimManager.AnimOverride = false
	if !CrouchRay.is_colliding():
		Source.PlayerCollision.shape.height = InitPlayerHeight
		Source.PlayerCollision.position.y = InitColPosition
		CameraPivot.CameraMarker.position.y = InitMarkerPos
		Source.isCrouched = false
