@icon("res://addons/IconGodotNode/node_3D/icon_boots.png")
extends Node

@export var Source: CharacterBody3D

var CoyoteTime : float = 0.3
var isJumping : bool = false

func _physics_process(_delta: float) -> void:
# Handle jump.
	if Input.is_action_just_pressed("MV_Jump") and Source.is_on_floor():
		isJumping = true
		Source.velocity.y = Source.Stat.JumpStrength
