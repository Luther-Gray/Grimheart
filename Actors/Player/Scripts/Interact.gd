@icon("res://addons/IconGodotNode/node_3D/icon_lever.png")
extends Node3D

@export var Source: CharacterBody3D

@export var AudioPlayer: AudioStreamPlayer3D
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@export var CameraPointer : RayCast3D

func _physics_process(delta: float) -> void:
	pass
