@icon("res://addons/IconGodotNode/node_3D/icon_sound.png")
extends Node3D

@export_category("Functionality")
@export var Source: CharacterBody3D
@export var AnimManager: AnimationManager
@export_category("Sound Files")
@export var ConcreteSteps: AudioStreamRandomizer
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	AnimManager.FootstepContact.connect(_on_footstep)

func _on_footstep() -> void:
	if !Source.is_on_floor() and !Source.isWallRunning:
		return
	AudioPlayer.stream = ConcreteSteps
	AudioPlayer.play()
