@icon("res://addons/IconGodotNode/node_3D/icon_wall.png")
extends Node3D

@export var Source: CharacterBody3D

@onready var WallL: RayCast3D = $"../WallRayL"
@onready var WallR: RayCast3D = $"../WallRayR"
@onready var ClamberShapeCast: ShapeCast3D = $"../ClamberShapecast"

var WallRunTimer : float = 0.0
var WallRunDuration : float = 0.3 # Replace this with stamina?

func _physics_process(delta: float) -> void:
	if Source.is_on_floor():
		WallRunTimer = WallRunDuration
	elif Source.isWallRunning and !Source.is_on_floor():
		WallRunTimer -= delta
	if Source.isFalling and Input.is_action_pressed("MV_Jump"):
		if WallR.is_colliding():
			pass
		elif WallL.is_colliding():
			pass
	elif Input.is_action_pressed("MV_Jump") and Source.isSprinting:
		if ClamberShapeCast.is_colliding():
			pass
	if WallRunTimer <= 0.0:
		_detatch_wall()

#// Physics - Wallruns are seperated for extra logic. Heavy 1 Handed Weapons. Broken Arms. Etc.
func _wall_run_v(): #// Upwards scramble
	Source.isWallRunning = true
	Source.velocity += Vector3(0,1,0)
func _wall_run_r(): #// Wallrun as long as stamina allows | RIGHT
	Source.isWallRunning = true
func _wall_run_l(): #// Wallrun as long as stamina allows | LEFT
	Source.isWallRunning = true
func _tic_tac(): #// Jump from wall
	pass
func _detatch_wall(): #// Lets go of wall
	Source.isWallRunning = false
