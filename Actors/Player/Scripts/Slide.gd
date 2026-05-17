@icon("res://addons/IconGodotNode/node_3D/icon_wheel.png")
extends Node3D

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@onready var AnimManager: AnimationManager = $"../AnimCenter"

var TargetPlayerHeight : float = 0.7
var TargetColPosition : float = 0.5
var TargetMarkerPos : float = -1

func _physics_process(_delta: float) -> void:
	if Source.Settings.CrouchToggle:
		if Input.is_action_just_pressed("MV_Crouch") and Source.isSprinting:
			pass
	elif !Source.Settings.CrouchToggle:
		if Input.is_action_pressed("MV_Crouch") and Source.isSprinting:
			pass

func _slide():
	Source.PlayerCollision.shape.height = TargetPlayerHeight
	Source.PlayerCollision.position.y = TargetColPosition
	CameraPivot.CameraMarker.position.y = TargetMarkerPos
	Source.isSliding = true
	AnimManager._override_travel("aSlide")
	AnimManager.AnimOverride = false
