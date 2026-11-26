@icon("res://addons/IconGodotNode/node_3D/icon_hand.png")
extends Node3D

@export var Source : CharacterBody3D

func _process(delta: float) -> void:
	if Source.isUnsheathed == false:
		return

func _physics_process(delta: float) -> void:
	pass

func _attack():
	pass
