@icon("res://addons/IconGodotNode/node_3D/icon_wind.png")
extends Node3D

@export var Source: CharacterBody3D

var SprintGrace : float = 0.5
var SprintTimer : float = 0.0

func _physics_process(delta: float) -> void:
	if Source.isVaulting or Source.isSliding:
		return
	if Source.Settings.SprintToggle and !Source.isCrouched:
		if Input.is_action_just_pressed("MV_Sprint") and Source.isMoving and Input.is_action_pressed("MV_Forward"):
			_toggle_sprint()
		elif !Source.isMoving or Input.is_action_pressed("MV_Backward"):
			_release_sprint()
	elif !Source.Settings.SprintToggle and !Source.isCrouched:
		if Input.is_action_pressed("MV_Sprint") and Source.isMoving:
			SprintTimer = SprintGrace
			_hold_sprint()
		elif Source.isSprinting and !Input.is_action_pressed("MV_Sprint"):
			SprintTimer -= delta
			if SprintTimer <= 0 or !Source.isMoving:
				_release_sprint()
			

func _toggle_sprint():
	Source.isSprinting = !Source.isSprinting
	Source.MoveSpeed = Source.Stat.SprintSpeed
func _hold_sprint():
	Source.isSprinting = true
	Source.MoveSpeed = Source.Stat.SprintSpeed
func _release_sprint():
	Source.isSprinting = false
	Source.MoveSpeed = Source.Stat.WalkSpeed
