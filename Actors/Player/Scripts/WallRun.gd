@icon("res://addons/IconGodotNode/node_3D/icon_wall.png")
extends Node3D

@export var Source: CharacterBody3D
@export var CameraPivot: Node3D
@export var WallRunSound: AudioStream
@export var TicTacSound: AudioStream
@export var AudioPlayer: AudioStreamPlayer3D

var VerticalRunDuration : float = 0.4
var VerticalScrambleSpeed : float = 20.0
var TicTacStrength : float = 4.0
var TicTacAngle : float = 4.0

@onready var WallL: RayCast3D = $"../WallRayL"
@onready var WallR: RayCast3D = $"../WallRayR"
@onready var ClamberShapeCast: ShapeCast3D = $"../ClamberShapecast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var Jump: Node3D = $"../Jump"
var WallRunTimer: float
var WallNormal : Vector3

func _physics_process(delta: float) -> void:
	if Source.isWallRunning:
		WallRunTimer -= delta
		if WallRunTimer <= 0.0:
			_detatch_wall()
		return
	if Input.is_action_just_pressed("MV_Jump") and Source.isSprinting and Source.is_on_floor() and ClamberShapeCast.get_collider(0):
		_wall_run_v()
	if Input.is_action_just_pressed("MV_Jump") and Source.isWallRunning and ClamberShapeCast.get_collider(0):
		_tic_tac()

#// Physics - Wallruns are seperated for extra conditionals. Heavy 1 Handed Weapons. Broken Arms. Etc.
func _wall_run_v() -> void: #// Upwards scramble
	if not ClamberShapeCast.is_colliding(): # Can you wallrun?
		return
	Source.isWallRunning = true
	WallNormal = ClamberShapeCast.get_collision_normal(0)
	Source.velocity.x = -WallNormal.x * 1.5
	Source.velocity.y = VerticalScrambleSpeed
	Source.velocity.z = -WallNormal.z * 1.5
	WallRunTimer = VerticalRunDuration
	#if AnimManager:
		#AnimManager._override_travel("aWallRunUp")
	#else:
		#return

func _wall_run_r() -> void: #// Wallrun as long as stamina allows | RIGHT
	pass

func _wall_run_l() -> void: #// Wallrun as long as stamina allows | LEFT
	pass

func _tic_tac() -> void: #// Jump from wall
	WallNormal = ClamberShapeCast.get_collision_normal(0)
	Source.velocity = WallNormal * TicTacStrength
	Source.velocity.y = TicTacAngle
	Jump.WasAirborne = true
	print_debug("EJECT")

func _detatch_wall() -> void: #// Lets go of wall
	Source.isWallRunning = false
