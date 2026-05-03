@icon("res://addons/IconGodotNode/node_3D/icon_wall.png")
extends Node3D

@export var Source: CharacterBody3D

@onready var WallL: RayCast3D = $"../WallRayL"
@onready var WallR: RayCast3D = $"../WallRayR"

#// Physics
func _wall_run_v(): #// Upwards scramble
	pass
func _wall_run_h(): #// Wallrun as long as stamina allows
	pass
func _tic_tac(): #// Jump from wall
	pass
func _detatch_wall(): #// Lets go of wall
	pass
