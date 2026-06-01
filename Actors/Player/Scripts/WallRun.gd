@icon("res://addons/IconGodotNode/node_3D/icon_wall.png")
extends Node3D

@export var Source: CharacterBody3D

@onready var WallL: RayCast3D = $"../WallRayL"
@onready var WallR: RayCast3D = $"../WallRayR"
@onready var ClamberShapeCast: ShapeCast3D = $"../ClamberShapecast"

var WallRunTimer : float = 0.0
var WallRunDuration : float = 5.0 # Replace this with stamina?

func _physics_process(_delta: float) -> void:
	if Source.isFalling:
		if WallR.is_colliding():
			_wall_run_r()
		elif WallL.is_colliding():
			_wall_run_l()
	if WallRunTimer <= 0.0:
		_detatch_wall()

#// Physics - Wallruns are seperated for extra logic. Heavy 1 Handed Weapons. Broken Arms. Etc.
func _wall_run_v(): #// Upwards scramble
	Source.isWallRunning = true
func _wall_run_r(): #// Wallrun as long as stamina allows | RIGHT
	Source.isWallRunning = true
func _wall_run_l(): #// Wallrun as long as stamina allows | LEFT
	Source.isWallRunning = true
func _tic_tac(): #// Jump from wall
	pass
func _detatch_wall(): #// Lets go of wall
	Source.isWallRunning = false
