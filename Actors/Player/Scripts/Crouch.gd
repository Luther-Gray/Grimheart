@icon("res://addons/IconGodotNode/node_3D/icon_cell.png")
extends Node3D

@onready var PlayerCollision: CollisionShape3D = $"../PlayerCollision"

@export var Source: CharacterBody3D
@export var Settings : Resource

func _unhandled_input(event: InputEvent) -> void:
	if Settings.CrouchToggle:
		if event.is_action_just_pressed("MV_Crouch"):
			_toggle_crouch()
			print(Source.isCrouched)
	elif !Settings.CrouchToggle:
		if event.is_action_pressed("MV_Crouch"):
			_hold_crouch()

func _toggle_crouch():
	Source.isCrouched = !Source.isCrouched

func _hold_crouch():
	pass
