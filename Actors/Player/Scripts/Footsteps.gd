@icon("res://addons/IconGodotNode/node_3D/icon_sound.png")
extends Node3D

@export_category("Functionality")
@export var Source: CharacterBody3D
@export var AnimManager: AnimationManager
@export_category("Sound Files")
@export var ConcreteSteps: AudioStreamRandomizer
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D

var PreviousFootstep: float = 0.0

const FootstepPoints: Dictionary = {
	"aWalkSpace": [0.1667, 0.5667],
	"aCrouchSpace": [0.1667, 0.7],
	"aSprint": [0.0667, 0.4333],
	"aWallRunL": [0.0333, 0.3667],
	"aWallRunR": [0.0333, 0.3667]
}

func _process(_delta: float) -> void:
	var CurrentAnimState: String = AnimManager.StateMachine.get_current_node()
	var FootstepPosition: float = AnimManager.StateMachine.get_current_play_position()

	if CurrentAnimState in FootstepPoints:
		for frame in FootstepPoints[CurrentAnimState]:
			if PreviousFootstep < frame and FootstepPosition >= frame:
				_on_footstep()
	PreviousFootstep = FootstepPosition

func _on_footstep() -> void:
	if !Source.is_on_floor() and !Source.isWallRunning:
		return
	AudioPlayer.stream = ConcreteSteps
	AudioPlayer.play()
