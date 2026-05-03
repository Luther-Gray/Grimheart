@icon("res://addons/IconGodotNode/node_3D/icon_boots.png")
extends Node

@export var Source: CharacterBody3D

var CoyoteTimer : float = 0.0
var CoyoteDuration : float = 0.15

func _physics_process(delta: float) -> void:
# Handle Fall
	if not Source.is_on_floor():
		Source.isFalling = Source.velocity.y < 0
	else:
		Source.isFalling = false
		Source.isJumping = false
# Handle jump.
	if Input.is_action_just_pressed("MV_Jump") and CoyoteTimer > 0:
		CoyoteTimer = 0
		Source.isJumping = true
		Source.velocity.y = Source.Stat.JumpStrength
	if Source.is_on_floor():
		CoyoteTimer = CoyoteDuration
	else:
		CoyoteTimer -= delta
