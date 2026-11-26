@icon("res://addons/IconGodotNode/node_3D/icon_wind.png")
extends Node3D

@export var Source: CharacterBody3D
@export var Camera : Camera3D

var SprintGrace : float = 0.5
var SprintTimer : float

func _physics_process(delta: float) -> void:
	if Source.isClambering or Source.isSliding:
		return
	if Source.Settings.SprintToggle and !Source.isCrouched:
		if Input.is_action_just_pressed("MV_Sprint") and Source.isMoving and Input.is_action_pressed("MV_Forward"):
			_toggle_sprint()
		elif !Source.isMoving or Input.is_action_pressed("MV_Backward") or Source.isClambering:
			_release_sprint(delta)
	elif !Source.Settings.SprintToggle and !Source.isCrouched:
		if Input.is_action_pressed("MV_Sprint") and Source.isMoving:
			SprintTimer = SprintGrace
			_hold_sprint()
		elif Source.isSprinting and !Input.is_action_pressed("MV_Sprint"):
			SprintTimer -= delta
			if SprintTimer <= 0 or !Source.isMoving or Source.isHanging:
				_release_sprint(delta)
			

func _toggle_sprint():
	Source.isSprinting = true
	Camera.fov = Source.Settings.CameraFOV * 1.1
	Source.MoveSpeed = Source.Stat.SprintSpeed
func _hold_sprint():
	Source.isSprinting = true
	Camera.fov = Source.Settings.CameraFOV * 1.1
	Source.MoveSpeed = Source.Stat.SprintSpeed
func _release_sprint(delta):
	Source.isSprinting = false
	Camera.fov = lerp(Camera.fov, Source.Settings.CameraFOV, 1 * delta)
	Source.MoveSpeed = Source.Stat.WalkSpeed
