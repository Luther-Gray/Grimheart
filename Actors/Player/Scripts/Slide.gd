@icon("res://addons/IconGodotNode/node_3D/icon_wheel.png")
extends Node3D

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@export var SlideSound : AudioStream
@export var AudioPlayer : AudioStreamPlayer3D
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var CrouchRay: RayCast3D = $"../CrouchRaycast"

#// Crouch Values
var InitPlayerHeight : float = 1.7
var InitColPosition : float = 0.85
var InitMarkerPos : float = 0.14
var TargetPlayerHeight : float = 0.95
var TargetColPosition : float = 0.5
var TargetMarkerPos : float = 0.0
var EndTargetMarkerPos : float = 0.0

#// Slide Values
var SlideTimer : float = 0.0
const SlideDuration : float = 0.8
const SlideBoost : float = 2.0

func _physics_process(delta: float) -> void:
	if Source.isSliding:
		if Source.is_on_floor():
			var FloorNormal = Source.get_floor_normal()
			var SlideDirection = -Source.global_transform.basis.z
			if FloorNormal.dot(Vector3.UP) < 0.95: # If on Slope, Reset Timer
				SlideTimer = SlideDuration
			elif FloorNormal.dot(Vector3.UP) < 0.95 and SlideDirection.dot(FloorNormal.slide(Vector3.UP).normalized()) > 0: # If trying to Slide UP a slope, don't slide.
				_end_slide()
				return
			else:
				SlideTimer -= delta
		if SlideTimer <= 0 or Input.is_action_just_pressed("MV_Jump"):
			_end_slide()
			return
	if Source.Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch") and Source.isSprinting and Source.is_on_floor():
			_slide()
	elif !Source.Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch") and Source.isSprinting and Source.is_on_floor():
			_slide()

func _slide():
	if SlideSound:
		AudioPlayer.stream = SlideSound
		AudioPlayer.play()
	SlideTimer = SlideDuration
	Source.PlayerCollision.shape.height = TargetPlayerHeight
	Source.PlayerCollision.position.y = TargetColPosition
	CameraPivot.CameraMarker.position.y = TargetMarkerPos
	Source.isSliding = true
	Source.isCrouched = true # Adding Crouch True here for extra functions tied to "crouched" abilities like sneak attacks.
	var SlideDirection = -Source.global_transform.basis.z
	Source.velocity += SlideDirection * SlideBoost
	AnimManager._override_travel("aSlide")
	

func _end_slide():
	Source.isSliding = false
	AnimManager.AnimOverride = false
	Source.isSprinting = false
	if !CrouchRay.is_colliding(): # If the Slide Ends and nothing is above you
		Source.PlayerCollision.shape.height = InitPlayerHeight
		Source.PlayerCollision.position.y = InitColPosition
		CameraPivot.CameraMarker.position.y = InitMarkerPos
		Source.MoveSpeed = Source.Stat.WalkSpeed
		Source.isCrouched = false
	else: # If the Slide Ends and you are under something -
		Source.PlayerCollision.shape.height = TargetPlayerHeight
		Source.PlayerCollision.position.y = TargetColPosition
		CameraPivot.CameraMarker.position.y = EndTargetMarkerPos
		Source.MoveSpeed = Source.Stat.CrouchSpeed
		Source.isCrouched = true
