@icon("res://addons/IconGodotNode/node_3D/icon_wall.png")
extends Node3D

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@export var WallRunSound: AudioStream
@export var TicTacSound: AudioStream
@export var AudioPlayer: AudioStreamPlayer3D

var WallRunTimer: float
var WallNormal : Vector3
var VerticalRunDuration : float = 0.8
var VerticalScrambleSpeed : float = 5.0
var TicTacStrength : float = 8.0
var TicTacAngle : float = 4.0

@onready var WallL: RayCast3D = $"../WallRayL"
@onready var WallR: RayCast3D = $"../WallRayR"
@onready var ClamberShapeCast: ShapeCast3D = $"../ClamberShapecast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var Jump: Node3D = $"../Jump"

func _physics_process(delta: float) -> void:
	if Source.isWallRunning:
		WallRunTimer -= delta
		AnimManager._override_travel("aWallRunUp")
		if WallRunSound:
			AudioPlayer.stream = WallRunSound
			AudioPlayer.play()
		if !ClamberShapeCast.is_colliding():
			_detatch_wall()
			return
		if Input.is_action_just_pressed("MV_Jump") and ClamberShapeCast.get_collider(0):
			_tic_tac()
			if TicTacSound:
				AudioPlayer.stream = TicTacSound
				AudioPlayer.play()
			return
		if WallRunTimer <= 0.0:
			_detatch_wall()
		return

	if Input.is_action_just_pressed("MV_Jump") and Source.isSprinting and Source.is_on_floor() and ClamberShapeCast.get_collider(0):
		_wall_run_v()

#// Physics - Wallruns are seperated for extra conditionals. Heavy 1 Handed Weapons. Broken Arms. Etc.
func _wall_run_v() -> void: #// Upwards scramble
	if not ClamberShapeCast.is_colliding(): # Can you wallrun?
		return
	Source.isWallRunning = true
	Source.isSprinting = false
	WallNormal = ClamberShapeCast.get_collision_normal(0)
	Source.velocity.x = -WallNormal.x * 1.5
	Source.velocity.y = VerticalScrambleSpeed
	Source.velocity.z = -WallNormal.z * 1.5
	WallRunTimer = VerticalRunDuration


func _wall_run_r() -> void: #// Wallrun as long as stamina allows | RIGHT
	pass

func _wall_run_l() -> void: #// Wallrun as long as stamina allows | LEFT
	pass

func _tic_tac() -> void: #// Jump from wall
	AnimManager._override_travel("aTicTac")
	if !ClamberShapeCast.is_colliding():
		return
	WallNormal = ClamberShapeCast.get_collision_normal(0)
	Source.velocity = WallNormal * TicTacStrength
	Source.velocity.y = TicTacAngle
	Jump.WasAirborne = true

func _detatch_wall() -> void: #// Lets go of wall
	Source.isWallRunning = false
	AnimManager.AnimOverride = false
