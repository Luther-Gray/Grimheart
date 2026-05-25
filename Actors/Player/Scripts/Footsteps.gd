@icon("res://addons/IconGodotNode/node_3D/icon_sound.png")
extends Node3D

@export_category("Functionality")
@export var Source: CharacterBody3D
@export_category("Sound Files")
@export var ConcreteSteps: AudioStreamRandomizer
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var LeftFootTip: Node3D
@export var RightFootTip: Node3D

var LeftFootId : int
var RightFootId : int
var LeftFootLastY : float = 0.0
var RightFootLastY : float = 0.0
var FloorLocation : float = 0.0
var StepCooldown: float = 0.0
const MIN_STEP_INTERVAL: float = 0.7

func _physics_process(delta: float) -> void:
	if !Source.is_on_floor() or !Source.isMoving or Source.isHanging:
		StepCooldown = 0.0
		return

	StepCooldown = max(0.0, StepCooldown - delta)

	var LeftY = LeftFootTip.global_position.y
	var RightY = RightFootTip.global_position.y
	var FloorY = _get_floor_y()

	if StepCooldown <= 0.0:
		if LeftY <= FloorY + 0.05 and LeftY < LeftFootLastY:
			_play_step()
			var Speed = Vector3(Source.velocity.x, 0, Source.velocity.z).length()
			StepCooldown = clamp((1.8/Speed), 0.15, 0.85)
		elif RightY <= FloorY + 0.05 and RightY < RightFootLastY:
			_play_step()
			var Speed = Vector3(Source.velocity.x, 0, Source.velocity.z).length()
			StepCooldown = clamp((1.8/Speed), 0.15, 0.85)

	LeftFootLastY = LeftY
	RightFootLastY = RightY

func _get_floor_y() -> float:
	return Source.global_position.y

func _play_step():
	AudioPlayer.stream = ConcreteSteps
	AudioPlayer.play()
